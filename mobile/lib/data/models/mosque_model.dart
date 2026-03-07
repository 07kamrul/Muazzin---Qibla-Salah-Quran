import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatting.dart';
import '../../core/utils/haversine.dart';

enum VerificationStatus { verified, community, unverified }

class JamatTimesModel {
  const JamatTimesModel({
    this.fajr,
    this.dhuhr,
    this.asr,
    this.maghrib,
    this.isha,
    this.jumuah,
  });

  final String? fajr;
  final String? dhuhr;
  final String? asr;
  final String? maghrib;
  final String? isha;
  final String? jumuah;

  bool get hasAny =>
      fajr != null || dhuhr != null || asr != null ||
      maghrib != null || isha != null || jumuah != null;

  Map<String, dynamic> toJson() => {
    'fajr':    fajr,
    'dhuhr':   dhuhr,
    'asr':     asr,
    'maghrib': maghrib,
    'isha':    isha,
    'jumuah':  jumuah,
  };

  factory JamatTimesModel.fromJson(Map<String, dynamic> json) =>
      JamatTimesModel(
        fajr:    json['fajr']    as String?,
        dhuhr:   json['dhuhr']   as String?,
        asr:     json['asr']     as String?,
        maghrib: json['maghrib'] as String?,
        isha:    json['isha']    as String?,
        jumuah:  json['jumuah']  as String?,
      );
}

class FacilitiesModel {
  const FacilitiesModel({
    this.womensSection = false,
    this.wudu          = false,
    this.ac            = false,
    this.parking       = false,
    this.wheelchair    = false,
  });

  final bool womensSection;
  final bool wudu;
  final bool ac;
  final bool parking;
  final bool wheelchair;

  Map<String, dynamic> toJson() => {
    'womens_section': womensSection,
    'wudu':           wudu,
    'ac':             ac,
    'parking':        parking,
    'wheelchair':     wheelchair,
  };

  factory FacilitiesModel.fromJson(Map<String, dynamic> json) =>
      FacilitiesModel(
        womensSection: json['womens_section'] as bool? ?? false,
        wudu:          json['wudu']           as bool? ?? false,
        ac:            json['ac']             as bool? ?? false,
        parking:       json['parking']        as bool? ?? false,
        wheelchair:    json['wheelchair']     as bool? ?? false,
      );
}

class MosqueModel {
  const MosqueModel({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.latitude,
    required this.longitude,
    required this.district,
    required this.upazila,
    this.division,
    this.addressBn,
    this.addressEn,
    required this.jamatTimes,
    required this.facilities,
    required this.verificationStatus,
    this.distanceKm,
  });

  final String             id;
  final String             nameBn;
  final String             nameEn;
  final double             latitude;
  final double             longitude;
  final String             district;
  final String             upazila;
  final String?            division;
  final String?            addressBn;
  final String?            addressEn;
  final JamatTimesModel    jamatTimes;
  final FacilitiesModel    facilities;
  final VerificationStatus verificationStatus;
  final double?            distanceKm;

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color get pinColor => switch (verificationStatus) {
    VerificationStatus.verified   => AppColors.pinVerified,
    VerificationStatus.community  => AppColors.pinCommunity,
    VerificationStatus.unverified => AppColors.pinUnverified,
  };

  String distanceText(String lang) =>
      distanceKm != null ? Formatting.formatDistance(distanceKm!, lang) : '';

  /// Returns a copy with [distanceKm] computed from the given coordinates.
  MosqueModel withDistance(double userLat, double userLng) => MosqueModel(
    id:                 id,
    nameBn:             nameBn,
    nameEn:             nameEn,
    latitude:           latitude,
    longitude:          longitude,
    district:           district,
    upazila:            upazila,
    division:           division,
    addressBn:          addressBn,
    addressEn:          addressEn,
    jamatTimes:         jamatTimes,
    facilities:         facilities,
    verificationStatus: verificationStatus,
    distanceKm: Haversine.distanceKm(userLat, userLng, latitude, longitude),
  );

  // ── JSON ──────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id':                  id,
    'name_bn':             nameBn,
    'name_en':             nameEn,
    'latitude':            latitude,
    'longitude':           longitude,
    'district':            district,
    'upazila':             upazila,
    'division':            division,
    'address_bn':          addressBn,
    'address_en':          addressEn,
    'jamat_times':         jamatTimes.toJson(),
    'facilities':          facilities.toJson(),
    'verification_status': verificationStatus.name,
    'distance_km':         distanceKm,
  };

  factory MosqueModel.fromJson(Map<String, dynamic> json) => MosqueModel(
    id:        json['id']      as String,
    nameBn:    json['name_bn'] as String,
    nameEn:    json['name_en'] as String? ?? '',
    latitude:  (json['latitude']  as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    district:  json['district']   as String? ?? '',
    upazila:   json['upazila']    as String? ?? '',
    division:  json['division']   as String?,
    addressBn: json['address_bn'] as String?,
    addressEn: json['address_en'] as String?,
    jamatTimes: json['jamat_times'] != null
        ? JamatTimesModel.fromJson(json['jamat_times'] as Map<String, dynamic>)
        : const JamatTimesModel(),
    facilities: json['facilities'] != null
        ? FacilitiesModel.fromJson(json['facilities'] as Map<String, dynamic>)
        : const FacilitiesModel(),
    verificationStatus: VerificationStatus.values.firstWhere(
      (s) => s.name == json['verification_status'],
      orElse: () => VerificationStatus.unverified,
    ),
    distanceKm: (json['distance_km'] as num?)?.toDouble(),
  );
}
