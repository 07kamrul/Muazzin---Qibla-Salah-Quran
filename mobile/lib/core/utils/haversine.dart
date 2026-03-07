import 'dart:math' as math;

import '../constants/app_config.dart';

/// Haversine and great-circle utilities.
class Haversine {
  Haversine._();

  static const double _earthRadiusKm = 6371.0;

  // ── Distance ──────────────────────────────────────────────────────────────

  /// Returns the distance in kilometres between two lat/lng points.
  static double distanceKm(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  // ── Bearing ───────────────────────────────────────────────────────────────

  /// Returns the initial great-circle bearing (0–360°) from point 1 to point 2.
  static double bearingDeg(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    final lat1r = _toRad(lat1);
    final lat2r = _toRad(lat2);
    final dLng  = _toRad(lng2 - lng1);

    final y = math.sin(dLng) * math.cos(lat2r);
    final x = math.cos(lat1r) * math.sin(lat2r) -
               math.sin(lat1r) * math.cos(lat2r) * math.cos(dLng);

    final bearing = _toDeg(math.atan2(y, x));
    return (bearing + 360) % 360;
  }

  // ── Qibla ─────────────────────────────────────────────────────────────────

  /// Returns the true-north Qibla bearing from [userLat]/[userLng] to Kaaba.
  static double qiblaBearing(double userLat, double userLng) =>
      bearingDeg(userLat, userLng, AppConfig.kaabatLat, AppConfig.kaabatLng);

  // ── Helpers ───────────────────────────────────────────────────────────────

  static double _toRad(double deg) => deg * math.pi / 180.0;
  static double _toDeg(double rad) => rad * 180.0 / math.pi;
}
