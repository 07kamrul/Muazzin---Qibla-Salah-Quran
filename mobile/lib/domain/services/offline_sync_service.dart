import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/preferences_helper.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/models/hadith_model.dart';
import '../../data/models/mosque_model.dart';
import '../../data/models/surah_model.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService(ref.read(apiClientProvider));
});

// ── Sync service ──────────────────────────────────────────────────────────────

/// Handles background synchronization between the local SQLite cache
/// and the remote Django API. Follows offline-first: local data is
/// always shown immediately; sync runs in the background when online.
class OfflineSyncService {
  OfflineSyncService(this._api);

  final ApiClient _api;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  // ── Initialization ──────────────────────────────────────────────────────────

  /// Start listening for connectivity changes and trigger sync on reconnect.
  Future<void> initialize() async {
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((results) async {
      final isOnline = results.any(
        (r) => r == ConnectivityResult.mobile || r == ConnectivityResult.wifi,
      );
      if (isOnline) {
        await syncAll();
      }
    });

    // Run initial sync if online
    final result = await Connectivity().checkConnectivity();
    if (result != ConnectivityResult.none) {
      unawaited(syncAll());
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
  }

  // ── Full sync ───────────────────────────────────────────────────────────────

  /// Sync everything that is stale. Safe to call repeatedly — each sync
  /// method checks its own freshness condition.
  Future<void> syncAll() async {
    await Future.wait([
      syncHadiths(),
      syncQuranMetadata(),
    ]);
  }

  // ── Hadith sync ─────────────────────────────────────────────────────────────

  /// Downloads all 365 Hadiths from the backend if not already cached.
  Future<void> syncHadiths() async {
    try {
      final count = await DatabaseHelper.instance.getHadithCount();
      if (count >= 365) return; // Already have full set

      final raw  = await _api.getHadiths();
      final list = raw.map(HadithModel.fromJson).toList();
      await DatabaseHelper.instance.insertHadiths(list);
    } catch (e) {
      // Network error — hadiths.json bundled asset is the fallback
      // (loaded separately in main.dart during initialization)
    }
  }

  // ── Quran metadata sync ─────────────────────────────────────────────────────

  /// Downloads Surah metadata (no ayahs) if not already cached.
  Future<void> syncQuranMetadata() async {
    try {
      final count = await DatabaseHelper.instance.getSurahCount();
      if (count >= 114) return; // Already complete

      final raw   = await _api.getSurahs();
      final surahs = raw.map(SurahModel.fromJson).toList();
      await DatabaseHelper.instance.insertSurahs(surahs);
    } catch (e) {
      // Silently fail — ayahs will be fetched on demand per surah
    }
  }

  // ── Surah ayahs on-demand ───────────────────────────────────────────────────

  /// Fetch + cache a single surah's ayahs from the API.
  /// Returns null on failure (caller should use local cache if any).
  Future<SurahModel?> fetchAndCacheSurah(int surahNumber) async {
    try {
      final raw   = await _api.getSurah(surahNumber);
      final surah = SurahModel.fromJson(raw);
      await DatabaseHelper.instance.insertSurahWithAyahs(surah);
      return surah;
    } catch (e) {
      return null;
    }
  }

  // ── Mosque sync ─────────────────────────────────────────────────────────────

  /// Downloads mosques near [lat]/[lng] if the local cache is stale (>24 h).
  Future<void> syncMosquesNearby({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    try {
      final lastSync = await PreferencesHelper.instance.getMosqueSyncTime();
      if (lastSync != null) {
        final age = DateTime.now().difference(lastSync).inHours;
        if (age < 24) return; // Cache still fresh
      }

      final raw     = await _api.getMosquesNearby(lat: lat, lng: lng, radiusKm: radiusKm);
      final mosques = raw.map(MosqueModel.fromJson).toList();
      await DatabaseHelper.instance.upsertMosques(mosques);
      await PreferencesHelper.instance.setMosqueSyncTime(DateTime.now());
    } catch (e) {
      // Network error — local DB will be used
    }
  }

  // ── Pending contributions ───────────────────────────────────────────────────

  /// Upload any locally pending mosque contributions / jamat updates.
  Future<void> uploadPendingContributions() async {
    try {
      final pending = await DatabaseHelper.instance.getPendingContributions();
      for (final item in pending) {
        if (item['type'] == 'mosque') {
          await _api.submitMosque(item['data'] as Map<String, dynamic>);
        } else if (item['type'] == 'jamat') {
          await _api.updateJamatTimes(
            item['mosque_id'] as int,
            item['data'] as Map<String, dynamic>,
          );
        }
        await DatabaseHelper.instance.markContributionSynced(item['id'] as int);
      }
    } catch (e) {
      // Will retry next time connectivity is available
    }
  }
}

// ── Connectivity check helper ─────────────────────────────────────────────────

Future<bool> isOnline() async {
  final result = await Connectivity().checkConnectivity();
  return result != ConnectivityResult.none;
}
