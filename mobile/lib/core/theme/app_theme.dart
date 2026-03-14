import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // ── Shared radius values ──────────────────────────────────────────────────
  static const _cardRadius  = 12.0;
  static const _inputRadius = 10.0;
  static const _chipRadius  = 20.0;

  // ── NotoSansBengali text theme ────────────────────────────────────────────
  static TextTheme _textTheme(Color text, Color textLight) => TextTheme(
    displayLarge:  GoogleFonts.notoSansBengali(fontSize: 57, fontWeight: FontWeight.w400, color: text),
    displayMedium: GoogleFonts.notoSansBengali(fontSize: 45, fontWeight: FontWeight.w400, color: text),
    displaySmall:  GoogleFonts.notoSansBengali(fontSize: 36, fontWeight: FontWeight.w400, color: text),
    headlineLarge: GoogleFonts.notoSansBengali(fontSize: 32, fontWeight: FontWeight.w700, color: text),
    headlineMedium:GoogleFonts.notoSansBengali(fontSize: 28, fontWeight: FontWeight.w600, color: text),
    headlineSmall: GoogleFonts.notoSansBengali(fontSize: 24, fontWeight: FontWeight.w600, color: text),
    titleLarge:    GoogleFonts.notoSansBengali(fontSize: 22, fontWeight: FontWeight.w600, color: text),
    titleMedium:   GoogleFonts.notoSansBengali(fontSize: 16, fontWeight: FontWeight.w500, color: text),
    titleSmall:    GoogleFonts.notoSansBengali(fontSize: 14, fontWeight: FontWeight.w500, color: text),
    bodyLarge:     GoogleFonts.notoSansBengali(fontSize: 16, fontWeight: FontWeight.w400, color: text),
    bodyMedium:    GoogleFonts.notoSansBengali(fontSize: 14, fontWeight: FontWeight.w400, color: text),
    bodySmall:     GoogleFonts.notoSansBengali(fontSize: 12, fontWeight: FontWeight.w400, color: textLight),
    labelLarge:    GoogleFonts.notoSansBengali(fontSize: 14, fontWeight: FontWeight.w600, color: text),
    labelMedium:   GoogleFonts.notoSansBengali(fontSize: 12, fontWeight: FontWeight.w500, color: text),
    labelSmall:    GoogleFonts.notoSansBengali(fontSize: 11, fontWeight: FontWeight.w500, color: textLight),
  );

  // ── Light theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.light,
      primary:          AppColors.primaryGreen,
      onPrimary:        AppColors.white,
      secondary:        AppColors.gold,
      onSecondary:      AppColors.primaryGreenDark,
      surface:          AppColors.lightSurface,
      onSurface:        AppColors.lightText,
      background:       AppColors.lightBackground,
      onBackground:     AppColors.lightText,
      error:            AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: _textTheme(AppColors.lightText, AppColors.lightTextLight),
    appBarTheme: AppBarTheme(
      backgroundColor:    AppColors.primaryGreen,
      foregroundColor:    AppColors.white,
      elevation:          0,
      centerTitle:        false,
      titleTextStyle:     GoogleFonts.notoSansBengali(
        fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color:        AppColors.lightSurface,
      elevation:    2,
      shadowColor:  AppColors.primaryGreen.withOpacity(0.12),
      shape:        RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:            true,
      fillColor:         AppColors.lightSurface,
      border:            OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputRadius),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder:     OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputRadius),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder:     OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputRadius),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      hintStyle:         GoogleFonts.notoSansBengali(
        color: AppColors.lightTextMuted, fontSize: 14,
      ),
      contentPadding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:      AppColors.lightSurface,
      selectedItemColor:    AppColors.primaryGreen,
      unselectedItemColor:  AppColors.lightTextMuted,
      showUnselectedLabels: true,
      type:                 BottomNavigationBarType.fixed,
      selectedLabelStyle:   GoogleFonts.notoSansBengali(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.notoSansBengali(fontSize: 11),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding:         const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle:       GoogleFonts.notoSansBengali(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor:   AppColors.lightBackground,
      selectedColor:     AppColors.primaryGreen,
      labelStyle:        GoogleFonts.notoSansBengali(fontSize: 12),
      shape:             RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_chipRadius),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
    ),
  );

  // ── Dark theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreenLight,
      brightness: Brightness.dark,
      primary:      AppColors.primaryGreenLight,
      onPrimary:    AppColors.white,
      secondary:    AppColors.gold,
      onSecondary:  AppColors.darkBackground,
      surface:      AppColors.darkSurface,
      onSurface:    AppColors.darkText,
      background:   AppColors.darkBackground,
      onBackground: AppColors.darkText,
      error:        AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.sky0,
    textTheme: _textTheme(AppColors.darkText, AppColors.darkTextLight),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkText,
      elevation:       0,
      centerTitle:     false,
      titleTextStyle:  GoogleFonts.notoSansBengali(
        fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.darkText,
      ),
    ),
    cardTheme: CardThemeData(
      color:       AppColors.darkSurface,
      elevation:   2,
      shadowColor: Colors.black38,
      shape:       RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:        true,
      fillColor:     AppColors.darkSurface,
      border:        OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputRadius),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputRadius),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputRadius),
        borderSide: const BorderSide(color: AppColors.gold, width: 2),
      ),
      hintStyle: GoogleFonts.notoSansBengali(
        color: AppColors.darkTextMuted, fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:      AppColors.darkSurface,
      selectedItemColor:    AppColors.gold,
      unselectedItemColor:  AppColors.darkTextMuted,
      showUnselectedLabels: true,
      type:                 BottomNavigationBarType.fixed,
      selectedLabelStyle:   GoogleFonts.notoSansBengali(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.notoSansBengali(fontSize: 11),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
    ),
  );
}
