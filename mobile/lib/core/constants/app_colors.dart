import 'package:flutter/material.dart';

/// Central colour palette for Muazzin.
///
/// All colours are `const` so the compiler can inline them.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primaryGreen      = Color(0xFF1B4332);
  static const Color primaryGreenLight = Color(0xFF2D6A4F);
  static const Color primaryGreenDark  = Color(0xFF0A2618);
  static const Color gold              = Color(0xFFD4AF37);
  static const Color goldLight         = Color(0xFFE8C547);
  static const Color cream             = Color(0xFFF5F0E8);
  static const Color white             = Color(0xFFFFFFFF);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error   = Color(0xFFE74C3C);
  static const Color info    = Color(0xFF2980B9);

  // ── Prayer-time accent colours ───────────────────────────────────────────
  static const Color fajrColor    = Color(0xFF4A90D9); // pre-dawn blue
  static const Color shuruqColor  = Color(0xFFF5A623); // sunrise orange
  static const Color dhuhrColor   = Color(0xFFE8C547); // noon yellow-gold
  static const Color asrColor     = Color(0xFF7ED321); // afternoon green
  static const Color maghribColor = Color(0xFFFF6B35); // sunset orange-red
  static const Color ishaColor    = Color(0xFF4A6FA5); // night indigo

  // ── Light theme ──────────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F0E8);
  static const Color lightSurface    = Color(0xFFFFFFFF);
  static const Color lightBorder     = Color(0xFFE0D9CC);
  static const Color lightText       = Color(0xFF1A1A1A);
  static const Color lightTextLight  = Color(0xFF666666);
  static const Color lightTextMuted  = Color(0xFF999999);

  // ── Dark theme ───────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0D1B12);
  static const Color darkSurface    = Color(0xFF1A2E1F);
  static const Color darkBorder     = Color(0xFF2D4A35);
  static const Color darkText       = Color(0xFFF5F0E8);
  static const Color darkTextLight  = Color(0xFFB8C4BB);
  static const Color darkTextMuted  = Color(0xFF7A8F7E);

  // ── Mosque map pin colours ───────────────────────────────────────────────
  static const Color pinVerified   = Color(0xFF27AE60); // green
  static const Color pinCommunity  = Color(0xFFE67E22); // orange
  static const Color pinUnverified = Color(0xFF95A5A6); // gray

  // ── Helper: prayer name → accent colour ──────────────────────────────────
  static Color forPrayer(String prayer) => switch (prayer.toLowerCase()) {
    'fajr'    => fajrColor,
    'shuruq'  => shuruqColor,
    'dhuhr'   => dhuhrColor,
    'asr'     => asrColor,
    'maghrib' => maghribColor,
    'isha'    => ishaColor,
    _         => primaryGreen,
  };
}
