import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Dark palette ───────────────────────────────────────────────────────────
  static const Color bgDeep = Color(0xFF070D1A);
  static const Color bgCard = Color(0xFF0D1628);
  static const Color bgSurface = Color(0xFF111E35);
  static const Color accent = Color(0xFF00E5C3);
  static const Color accentSoft = Color(0xFF00B89A);
  static const Color accentGlow = Color(0x3300E5C3);
  static const Color doctorColor = Color(0xFF4DA8FF);
  static const Color patientColor = Color(0xFF00E5C3);
  static const Color warningColor = Color(0xFFFFB347);
  static const Color errorColor = Color(0xFFFF5C7A);
  static const Color textPrimary = Color(0xFFEFF6FF);
  static const Color textSecondary = Color(0xFF7A9CC0);
  static const Color textMuted = Color(0xFF3D5A7A);
  static const Color divider = Color(0xFF1A2E4A);

  // ── Light palette ──────────────────────────────────────────────────────────
  static const Color lBgDeep = Color(0xFFF0F6FF);
  static const Color lBgCard = Color(0xFFFFFFFF);
  static const Color lBgSurface = Color(0xFFE8F1FB);
  static const Color lAccent =
      Color(0xFF007A68); // darker for contrast on white
  static const Color lAccentGlow = Color(0x18007A68);
  static const Color lDoctorColor = Color(0xFF1260A8);
  static const Color lPatientColor = Color(0xFF007A68);
  static const Color lWarningColor = Color(0xFFE07B00);
  static const Color lErrorColor = Color(0xFFD63050);
  static const Color lTextPrimary = Color(0xFF0D1628);
  static const Color lTextSecondary = Color(0xFF3A5A80);
  static const Color lTextMuted = Color(0xFF8AAAC8);
  static const Color lDivider = Color(0xFFCEDEEF);

  static ThemeData get darkTheme => _build(Brightness.dark);
  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get theme => darkTheme; // legacy alias

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      scaffoldBackgroundColor: isDark ? bgDeep : lBgDeep,
      colorScheme: ColorScheme(
        brightness: b,
        primary: isDark ? accent : lAccent,
        onPrimary: isDark ? bgDeep : Colors.white,
        secondary: isDark ? doctorColor : lDoctorColor,
        onSecondary: Colors.white,
        surface: isDark ? bgCard : lBgCard,
        onSurface: isDark ? textPrimary : lTextPrimary,
        error: isDark ? errorColor : lErrorColor,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(TextTheme(
        displayLarge: TextStyle(
            color: isDark ? textPrimary : lTextPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0),
        displayMedium: TextStyle(
            color: isDark ? textPrimary : lTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5),
        titleLarge: TextStyle(
            color: isDark ? textPrimary : lTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600),
        titleMedium: TextStyle(
            color: isDark ? textSecondary : lTextSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5),
        bodyLarge: TextStyle(
            color: isDark ? textPrimary : lTextPrimary,
            fontSize: 16,
            height: 1.6),
        bodyMedium: TextStyle(
            color: isDark ? textSecondary : lTextSecondary,
            fontSize: 14,
            height: 1.5),
        labelLarge: TextStyle(
            color: isDark ? textPrimary : lTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8),
      )),
      cardTheme: CardThemeData(
        color: isDark ? bgCard : lBgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? divider : lDivider),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? accent : lAccent,
          foregroundColor: isDark ? bgDeep : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.5),
        ),
      ),
      dividerTheme:
          DividerThemeData(color: isDark ? divider : lDivider, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? bgDeep : lBgCard,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.dmSans(
          color: isDark ? textPrimary : lTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme:
            IconThemeData(color: isDark ? textSecondary : lTextSecondary),
      ),
    );
  }
}
