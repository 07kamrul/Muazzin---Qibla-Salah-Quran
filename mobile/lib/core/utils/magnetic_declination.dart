import 'dart:math' as math;

/// WMM-2025 approximate magnetic declination lookup for Bangladesh.
///
/// Uses a 16-point grid and inverse-distance weighting (IDW) interpolation.
class MagneticDeclination {
  MagneticDeclination._();

  /// Approximate WMM-2025 declination grid for Bangladesh.
  /// Each entry: [latitude, longitude, declination_degrees].
  /// Negative = West declination.
  static const List<List<double>> _grid = [
    // Dhaka division
    [23.81, 90.41, -0.48], // Dhaka
    [24.36, 88.60, -0.55], // Rajshahi
    [22.33, 91.84, -0.52], // Chittagong
    [24.90, 91.87, -0.45], // Sylhet
    [22.45, 89.55, -0.50], // Khulna
    [22.70, 90.36, -0.49], // Barisal
    [24.75, 90.41, -0.47], // Mymensingh
    [25.75, 89.25, -0.53], // Rangpur
    // Extra nodes for better coverage
    [23.00, 89.00, -0.51],
    [23.00, 91.50, -0.50],
    [24.50, 90.00, -0.49],
    [22.00, 90.50, -0.50],
    [25.00, 88.50, -0.54],
    [25.50, 90.50, -0.46],
    [22.50, 92.00, -0.53],
    [24.00, 92.00, -0.44],
  ];

  /// Returns the approximate magnetic declination in degrees for [lat]/[lng].
  ///
  /// Negative result = West declination (bearing correction: subtract).
  static double getDeclination(double lat, double lng) {
    // IDW (p=2)
    double weightedSum  = 0.0;
    double totalWeight  = 0.0;

    for (final point in _grid) {
      final dLat = lat - point[0];
      final dLng = lng - point[1];
      final dist = math.sqrt(dLat * dLat + dLng * dLng);

      if (dist < 1e-6) return point[2]; // exact match
      final w = 1.0 / (dist * dist);   // inverse-distance squared
      weightedSum += w * point[2];
      totalWeight += w;
    }

    return totalWeight > 0 ? weightedSum / totalWeight : -0.50;
  }

  /// Converts a true-north bearing to a magnetic bearing.
  static double trueToMagnetic(double trueBearing, double lat, double lng) {
    final decl = getDeclination(lat, lng);
    return (trueBearing - decl + 360) % 360;
  }

  /// Converts a magnetic bearing to a true-north bearing.
  static double magneticToTrue(double magneticBearing, double lat, double lng) {
    final decl = getDeclination(lat, lng);
    return (magneticBearing + decl + 360) % 360;
  }
}
