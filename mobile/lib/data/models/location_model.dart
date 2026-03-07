enum LocationSource { gps, ip, manual }

class LocationModel {
  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.district,
    required this.division,
    this.upazila,
    this.accuracy,
    required this.source,
    required this.timestamp,
  });

  final double         latitude;
  final double         longitude;
  final String         city;
  final String         district;
  final String         division;
  final String?        upazila;
  final double?        accuracy;
  final LocationSource source;
  final int            timestamp; // millisecondsSinceEpoch

  /// Used as SQLite cache key.
  String get locationKey =>
      '${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';

  /// Returns `true` if the cached location is older than 6 hours.
  bool get isStale {
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    return age > const Duration(hours: 6).inMilliseconds;
  }

  LocationModel copyWith({
    double?         latitude,
    double?         longitude,
    String?         city,
    String?         district,
    String?         division,
    String?         upazila,
    double?         accuracy,
    LocationSource? source,
    int?            timestamp,
  }) =>
      LocationModel(
        latitude:  latitude  ?? this.latitude,
        longitude: longitude ?? this.longitude,
        city:      city      ?? this.city,
        district:  district  ?? this.district,
        division:  division  ?? this.division,
        upazila:   upazila   ?? this.upazila,
        accuracy:  accuracy  ?? this.accuracy,
        source:    source    ?? this.source,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toJson() => {
    'latitude':  latitude,
    'longitude': longitude,
    'city':      city,
    'district':  district,
    'division':  division,
    'upazila':   upazila,
    'accuracy':  accuracy,
    'source':    source.name,
    'timestamp': timestamp,
  };

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    latitude:  (json['latitude']  as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    city:      json['city']      as String? ?? '',
    district:  json['district']  as String? ?? '',
    division:  json['division']  as String? ?? '',
    upazila:   json['upazila']   as String?,
    accuracy:  (json['accuracy'] as num?)?.toDouble(),
    source:    LocationSource.values.firstWhere(
      (s) => s.name == json['source'],
      orElse: () => LocationSource.manual,
    ),
    timestamp: json['timestamp'] as int,
  );
}
