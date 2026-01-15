import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode { neonGym, cleanMinimal, sportyEnergy }

class AppThemes {
  // ═══════════════════════════════════════════════════════════════════════════
  // NEON GYM THEME - Dark, intense, gym feel
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData neonGymTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0A0F),
    primaryColor: const Color(0xFF00F5FF), // Electric Cyan
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00F5FF),
      secondary: Color(0xFFFF006E), // Hot Pink
      surface: Color(0xFF1A1A2E),
      error: Color(0xFFFF4757),
      onPrimary: Color(0xFF0A0A0F),
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.rajdhaniTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.w700,
          color: Color(0xFF00F5FF),
          letterSpacing: 4,
        ),
        displayMedium: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white60,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF00F5FF),
          letterSpacing: 2,
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1A1A2E),
      elevation: 8,
      shadowColor: const Color(0xFF00F5FF).withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF00F5FF), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00F5FF),
        foregroundColor: const Color(0xFF0A0A0F),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.rajdhani(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFFF006E),
        side: const BorderSide(color: Color(0xFFFF006E), width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF00F5FF)),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.rajdhani(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF00F5FF),
        letterSpacing: 3,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF00F5FF)),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Color(0xFF00F5FF),
      inactiveTrackColor: Color(0xFF2D2D44),
      thumbColor: Color(0xFFFF006E),
      overlayColor: Color(0x2900F5FF),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF00F5FF),
      linearTrackColor: Color(0xFF2D2D44),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEAN MINIMAL THEME - Modern, calm, focused
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData cleanMinimalTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    primaryColor: const Color(0xFF2D3436), // Slate Gray
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2D3436),
      secondary: Color(0xFFFF7675), // Coral
      surface: Colors.white,
      error: Color(0xFFD63031),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF2D3436),
    ),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.w300,
          color: Color(0xFF2D3436),
        ),
        displayMedium: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w400,
          color: Color(0xFF2D3436),
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3436),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3436),
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3436),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF636E72),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF636E72),
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3436),
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D3436),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFFF7675),
        side: const BorderSide(color: Color(0xFFFF7675), width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D3436),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Color(0xFF2D3436),
      inactiveTrackColor: Color(0xFFDFE6E9),
      thumbColor: Color(0xFFFF7675),
      overlayColor: Color(0x29FF7675),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFFFF7675),
      linearTrackColor: Color(0xFFDFE6E9),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SPORTY ENERGY THEME - Vibrant, motivating
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData sportyEnergyTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A0A2E), // Deep Purple
    primaryColor: const Color(0xFFB8FF00), // Lime Green
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFB8FF00),
      secondary: Color(0xFFFF9500), // Orange
      surface: Color(0xFF2D1B4E),
      error: Color(0xFFFF4757),
      onPrimary: Color(0xFF1A0A2E),
      onSecondary: Color(0xFF1A0A2E),
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.oswaldTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.w700,
          color: Color(0xFFB8FF00),
        ),
        displayMedium: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white60,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFB8FF00),
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF2D1B4E),
      elevation: 8,
      shadowColor: const Color(0xFFB8FF00).withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB8FF00),
        foregroundColor: const Color(0xFF1A0A2E),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.oswald(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFFF9500),
        side: const BorderSide(color: Color(0xFFFF9500), width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFB8FF00)),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.oswald(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFB8FF00),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFB8FF00)),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Color(0xFFB8FF00),
      inactiveTrackColor: Color(0xFF3D2B5E),
      thumbColor: Color(0xFFFF9500),
      overlayColor: Color(0x29B8FF00),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFFB8FF00),
      linearTrackColor: Color(0xFF3D2B5E),
    ),
  );

  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.neonGym:
        return neonGymTheme;
      case AppThemeMode.cleanMinimal:
        return cleanMinimalTheme;
      case AppThemeMode.sportyEnergy:
        return sportyEnergyTheme;
    }
  }

  static String getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.neonGym:
        return 'Neon Gym';
      case AppThemeMode.cleanMinimal:
        return 'Clean Minimal';
      case AppThemeMode.sportyEnergy:
        return 'Sporty Energy';
    }
  }

  static String getThemeEmoji(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.neonGym:
        return '🌙';
      case AppThemeMode.cleanMinimal:
        return '☀️';
      case AppThemeMode.sportyEnergy:
        return '⚡';
    }
  }
}
