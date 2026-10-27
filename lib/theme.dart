import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF0F6B50);
  static const mint = Color(0xFFDFF4EC);
  static const background = Color(0xFFF8FAF9);
  static const text = Color(0xFF1F2933);
  static const muted = Color(0xFF667085);
  static const warning = Color(0xFFF4A825);
}

/// Builds the app theme. Inter for English, Noto Nastaliq Urdu for Urdu.
/// [useGoogleFonts] is false in tests, which have no network.
ThemeData buildTheme(String lang, {bool useGoogleFonts = true}) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondaryContainer: AppColors.mint,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );
  var textTheme = base.textTheme.apply(
    bodyColor: AppColors.text,
    displayColor: AppColors.text,
  );
  if (useGoogleFonts) {
    textTheme = lang == 'ur'
        ? GoogleFonts.notoNastaliqUrduTextTheme(textTheme)
        : GoogleFonts.interTextTheme(textTheme);
  }
  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE4E9E7)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.mint,
    ),
  );
}

IconData categoryIcon(String id) => switch (id) {
  'education' => Icons.school_outlined,
  'documents' => Icons.badge_outlined,
  'travel' => Icons.flight_takeoff,
  'government' => Icons.account_balance_outlined,
  _ => Icons.description_outlined,
};

const categoryIds = ['education', 'documents', 'travel', 'government'];

/// Nastaliq script needs much more line spacing than Latin text.
double bodyLineHeight(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ur' ? 2.0 : 1.5;
