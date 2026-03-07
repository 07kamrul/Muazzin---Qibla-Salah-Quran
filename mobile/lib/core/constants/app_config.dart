/// App-wide configuration constants for Muazzin.
class AppConfig {
  AppConfig._();

  // ── Kaaba coordinates ────────────────────────────────────────────────────
  static const double kaabatLat = 21.4225;
  static const double kaabatLng = 39.8262;

  // ── Bangladesh timezone ──────────────────────────────────────────────────
  static const String bdTimezone    = 'Asia/Dhaka';
  static const int    utcOffsetHours = 6;

  // ── Prayer calculation (Hanafi / Karachi) ────────────────────────────────
  static const double fajrAngle  = 18.0;
  static const double ishaAngle  = 18.0;
  static const int    asrShadowRatio = 2; // Hanafi: 2× object height

  // ── Caching ──────────────────────────────────────────────────────────────
  static const int prayerCacheDays    = 30;
  static const int locationCacheHours = 6;

  // ── Travel mode ──────────────────────────────────────────────────────────
  static const double travelModeThresholdKm = 10.0;

  // ── Mosque search ────────────────────────────────────────────────────────
  static const List<int> mosqueSearchRadii      = [1, 3, 5, 10]; // km
  static const int       mosqueDefaultRadiusKm  = 1;
  static const int       mosqueAutoExpandMinResults = 3;

  // ── Jamat verification ───────────────────────────────────────────────────
  static const int jamatVerificationMinSubmissions = 3;
  static const int jamatVerificationWindowMinutes  = 5;

  // ── Offline map budget ───────────────────────────────────────────────────
  static const int maxOfflineMapMb = 50;

  // ── Qibla ────────────────────────────────────────────────────────────────
  static const double qiblaAlignmentToleranceDeg = 2.0;

  // ── Hadith ───────────────────────────────────────────────────────────────
  static const int hadithNotificationHour    = 8;
  static const List<int> sehriAlertMinutes   = [30, 15, 5];

  // ── API ──────────────────────────────────────────────────────────────────
  static const String apiBaseUrl      = 'http://localhost:8000/api/v1';
  static const String nominatimUrl    = 'https://nominatim.openstreetmap.org';
  static const String overpassUrl     = 'https://overpass-api.de/api/interpreter';
  static const String quranAudioBase  =
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy';

  // ── OpenStreetMap tile server ────────────────────────────────────────────
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
}
