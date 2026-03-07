import '../../core/constants/app_config.dart';
import '../../core/utils/haversine.dart';
import '../../core/utils/magnetic_declination.dart';

/// Qibla direction service.
class QiblaService {
  QiblaService._();
  static final QiblaService instance = QiblaService._();

  /// Returns the true-north bearing from [userLat]/[userLng] to Kaaba.
  double calculateTrueBearing(double userLat, double userLng) =>
      Haversine.qiblaBearing(userLat, userLng);

  /// Returns the magnetic-north Qibla bearing (corrected for WMM declination).
  double getQiblaBearing(double userLat, double userLng) {
    final trueBearing  = calculateTrueBearing(userLat, userLng);
    final declination  = MagneticDeclination.getDeclination(userLat, userLng);
    return (trueBearing - declination + 360) % 360;
  }

  /// Returns `true` if [compassHeading] is within the alignment tolerance of [qiblaBearing].
  bool isAlignedWithQibla(double compassHeading, double qiblaBearing) {
    final deviation = getDeviation(compassHeading, qiblaBearing).abs();
    return deviation <= AppConfig.qiblaAlignmentToleranceDeg;
  }

  /// Returns the signed deviation in degrees (negative = turn left, positive = turn right).
  double getDeviation(double compassHeading, double qiblaBearing) {
    double diff = qiblaBearing - compassHeading;
    // Normalise to -180 … +180
    while (diff > 180)  diff -= 360;
    while (diff < -180) diff += 360;
    return diff;
  }

  /// Returns a cardinal direction label for [bearing].
  String cardinalDirection(double bearing, String lang) {
    const cardinalsBn = ['উত্তর', 'উত্তর-পূর্ব', 'পূর্ব', 'দক্ষিণ-পূর্ব',
                         'দক্ষিণ', 'দক্ষিণ-পশ্চিম', 'পশ্চিম', 'উত্তর-পশ্চিম'];
    const cardinalsEn = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final idx = ((bearing + 22.5) % 360 ~/ 45).clamp(0, 7);
    return lang == 'bn' ? cardinalsBn[idx] : cardinalsEn[idx];
  }
}
