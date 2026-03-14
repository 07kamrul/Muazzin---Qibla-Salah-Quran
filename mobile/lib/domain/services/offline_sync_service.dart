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

class OfflineSyncService {
  OfflineSyncService(this._api);

  final ApiClient _api;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  Future<void> initialize() async {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) async {
      final isOnline = results.any(
        (r) => r == ConnectivityResult.mobile || r == ConnectivityResult.wifi,
      );
      if (isOnline) await syncAll();
    });

    final result = await Connectivity().checkConnectivity();
    if (result != ConnectivityResult.none) {
      unawaited(syncAll());
    }
  }

  void dispose() => _connectivitySub?.cancel();

  Future<void> syncAll() async {
    await Future.wait([syncHadiths(), syncQuranMetadata()]);
  }

  Future<void> syncHadiths() async {
    try {
      final lastDate = await PreferencesHelper.instance.loadLastHadithDate();
      if (lastDate != null) {
        final today = DateTime.now();
        if (lastDate.year == today.year &&
            lastDate.month == today.month &&
            lastDate.day == today.day) return;
      }
      final raw  = await _api.getHadiths();
      final list = raw.map(HadithModel.fromJson).toList();
      await DatabaseHelper.instance.saveHadiths(list);
      await PreferencesHelper.instance.saveLastHadithDate(DateTime.now());
    } catch (_) {}
  }

  // Quran data is served from API on demand; no local DB caching needed.
  Future<void> syncQuranMetadata() async {}

  Future<SurahModel?> fetchAndCacheSurah(int surahNumber) async {
    try {
      final raw = await _api.getSurah(surahNumber);
      return SurahModel.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> syncMosquesNearby({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    try {
      final lastSync = await PreferencesHelper.instance.getMosqueSyncTime();
      if (lastSync != null &&
          DateTime.now().difference(lastSync).inHours < 24) return;

      final raw     = await _api.getMosquesNearby(lat: lat, lng: lng, radiusKm: radiusKm);
      final mosques = raw.map(MosqueModel.fromJson).toList();
      await DatabaseHelper.instance.saveMosques(mosques);
      await PreferencesHelper.instance.setMosqueSyncTime(DateTime.now());
    } catch (_) {}
  }

  Future<void> uploadPendingContributions() async {}
}

Future<bool> isOnline() async {
  final result = await Connectivity().checkConnectivity();
  return result != ConnectivityResult.none;
}
