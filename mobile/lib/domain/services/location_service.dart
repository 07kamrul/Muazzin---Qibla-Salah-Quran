import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

import '../../data/datasources/local/preferences_helper.dart';
import '../../data/models/location_model.dart';
import '../../core/utils/haversine.dart';
import '../../core/constants/app_config.dart';

class LocationException implements Exception {
  const LocationException(this.message);
  final String message;
  @override
  String toString() => 'LocationException: $message';
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));

  // ── Main entry point ──────────────────────────────────────────────────────

  /// Returns the best available location: GPS → IP → cached → error.
  Future<LocationModel> getLocation() async {
    // 1. Try GPS
    try {
      final loc = await getCurrentLocation();
      await PreferencesHelper.instance.saveLocation(loc);
      return loc;
    } catch (_) {}

    // 2. Try IP geolocation
    try {
      final loc = await getLocationByIP();
      await PreferencesHelper.instance.saveLocation(loc);
      return loc;
    } catch (_) {}

    // 3. Return cached if available
    final cached = await PreferencesHelper.instance.loadLocation();
    if (cached != null) return cached;

    throw const LocationException('অবস্থান নির্ধারণ করা যায়নি');
  }

  // ── GPS ───────────────────────────────────────────────────────────────────

  Future<LocationModel> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw const LocationException('GPS disabled');

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException('Location permission permanently denied');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );

    final geo = await reverseGeocode(position.latitude, position.longitude);

    return LocationModel(
      latitude:  position.latitude,
      longitude: position.longitude,
      city:      geo['city']     ?? '',
      district:  geo['district'] ?? '',
      division:  geo['division'] ?? '',
      upazila:   geo['upazila'],
      accuracy:  position.accuracy,
      source:    LocationSource.gps,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ── IP geolocation ────────────────────────────────────────────────────────

  Future<LocationModel> getLocationByIP() async {
    final response = await _dio.get<Map<String, dynamic>>('https://ipapi.co/json/');
    final data     = response.data!;

    final lat = (data['latitude']  as num?)?.toDouble() ?? 23.81;
    final lng = (data['longitude'] as num?)?.toDouble() ?? 90.41;
    final city = data['city'] as String? ?? '';

    return LocationModel(
      latitude:  lat,
      longitude: lng,
      city:      city,
      district:  city,
      division:  data['region'] as String? ?? '',
      source:    LocationSource.ip,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ── Reverse geocoding (Nominatim) ─────────────────────────────────────────

  Future<Map<String, String?>> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${AppConfig.nominatimUrl}/reverse',
        queryParameters: {
          'lat': lat, 'lon': lng, 'format': 'json',
          'accept-language': 'en',
        },
        options: Options(headers: {'User-Agent': 'Muazzin-App/1.0'}),
      );
      final address = response.data?['address'] as Map<String, dynamic>? ?? {};
      return {
        'city':     address['city'] as String? ??
                    address['town'] as String? ??
                    address['village'] as String?,
        'district': address['county'] as String? ?? address['state_district'] as String?,
        'division': address['state'] as String?,
        'upazila':  address['suburb'] as String?,
      };
    } catch (_) {
      return {'city': null, 'district': null, 'division': null, 'upazila': null};
    }
  }

  // ── Travel mode ───────────────────────────────────────────────────────────

  bool detectTravelMode(LocationModel prev, LocationModel current) {
    final dist = Haversine.distanceKm(
      prev.latitude, prev.longitude, current.latitude, current.longitude,
    );
    return dist > AppConfig.travelModeThresholdKm;
  }

  // ── BD divisions & districts (static data) ────────────────────────────────

  static const List<String> divisions = [
    'ঢাকা', 'চট্টগ্রাম', 'সিলেট', 'রাজশাহী',
    'খুলনা', 'বরিশাল', 'ময়মনসিংহ', 'রংপুর',
  ];

  static const Map<String, List<String>> districtsByDivision = {
    'ঢাকা':      ['ঢাকা', 'গাজীপুর', 'নারায়ণগঞ্জ', 'মানিকগঞ্জ', 'মুন্সিগঞ্জ', 'নরসিংদী', 'কিশোরগঞ্জ', 'টাঙ্গাইল', 'ফরিদপুর', 'মাদারীপুর', 'শরিয়তপুর', 'রাজবাড়ী', 'গোপালগঞ্জ'],
    'চট্টগ্রাম':  ['চট্টগ্রাম', 'কক্সবাজার', 'রাঙ্গামাটি', 'বান্দরবান', 'খাগড়াছড়ি', 'ফেনী', 'কুমিল্লা', 'ব্রাহ্মণবাড়িয়া', 'চাঁদপুর', 'লক্ষ্মীপুর', 'নোয়াখালী'],
    'সিলেট':     ['সিলেট', 'মৌলভীবাজার', 'হবিগঞ্জ', 'সুনামগঞ্জ'],
    'রাজশাহী':   ['রাজশাহী', 'নাটোর', 'নওগাঁ', 'চাঁপাইনবাবগঞ্জ', 'পাবনা', 'সিরাজগঞ্জ', 'বগুড়া', 'জয়পুরহাট'],
    'খুলনা':     ['খুলনা', 'যশোর', 'সাতক্ষীরা', 'বাগেরহাট', 'নড়াইল', 'মাগুরা', 'ঝিনাইদহ', 'কুষ্টিয়া', 'মেহেরপুর', 'চুয়াডাঙ্গা'],
    'বরিশাল':    ['বরিশাল', 'পটুয়াখালী', 'পিরোজপুর', 'ঝালকাঠি', 'বরগুনা', 'ভোলা'],
    'ময়মনসিংহ': ['ময়মনসিংহ', 'জামালপুর', 'নেত্রকোনা', 'শেরপুর'],
    'রংপুর':     ['রংপুর', 'দিনাজপুর', 'নীলফামারী', 'পঞ্চগড়', 'ঠাকুরগাঁও', 'কুড়িগ্রাম', 'লালমনিরহাট', 'গাইবান্ধা'],
  };
}
