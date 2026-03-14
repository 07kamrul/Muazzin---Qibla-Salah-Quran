import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/location_model.dart';
import '../../models/user_settings_model.dart';

class PreferencesHelper {
  PreferencesHelper._();
  static final PreferencesHelper instance = PreferencesHelper._();

  SharedPreferences? _prefs;

  static const _kSettings       = 'user_settings';
  static const _kLocation       = 'cached_location';
  static const _kLastHadithDate  = 'last_hadith_date';
  static const _kMosqueSyncTime  = 'mosque_sync_time';
  static const _kAuthToken       = 'auth_access_token';
  static const _kRefreshToken    = 'auth_refresh_token';

  Future<void> init() async => _prefs ??= await SharedPreferences.getInstance();

  Future<SharedPreferences> get _p async {
    if (_prefs != null) return _prefs!;
    await init();
    return _prefs!;
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  Future<void> saveSettings(UserSettingsModel s) async =>
      (await _p).setString(_kSettings, jsonEncode(s.toJson()));

  Future<UserSettingsModel> loadSettings() async {
    try {
      final raw = (await _p).getString(_kSettings);
      if (raw == null) return UserSettingsModel.defaults();
      return UserSettingsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('loadSettings error: $e');
      return UserSettingsModel.defaults();
    }
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> saveLocation(LocationModel loc) async =>
      (await _p).setString(_kLocation, jsonEncode(loc.toJson()));

  Future<LocationModel?> loadLocation() async {
    try {
      final raw = (await _p).getString(_kLocation);
      if (raw == null) return null;
      return LocationModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // ── Hadith ────────────────────────────────────────────────────────────────

  Future<void> saveLastHadithDate(DateTime d) async =>
      (await _p).setString(_kLastHadithDate, d.toIso8601String());

  Future<DateTime?> loadLastHadithDate() async {
    final raw = (await _p).getString(_kLastHadithDate);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  // ── Mosque sync ───────────────────────────────────────────────────────────

  Future<void> setMosqueSyncTime(DateTime d) async =>
      (await _p).setString(_kMosqueSyncTime, d.toIso8601String());

  Future<DateTime?> getMosqueSyncTime() async {
    final raw = (await _p).getString(_kMosqueSyncTime);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> saveAuthToken(String t)    async => (await _p).setString(_kAuthToken, t);
  Future<String?> loadAuthToken()          async => (await _p).getString(_kAuthToken);
  Future<void> saveRefreshToken(String t) async => (await _p).setString(_kRefreshToken, t);
  Future<String?> loadRefreshToken()       async => (await _p).getString(_kRefreshToken);

  Future<void> clearAuthToken() async {
    final p = await _p;
    await p.remove(_kAuthToken);
    await p.remove(_kRefreshToken);
  }
}
