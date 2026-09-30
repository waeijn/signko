import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── SignKo Color Palette ──────────────────────────────────────────────

  // Primary Brand
  static const Color _royalBlue = Color(0xFF1E56F0);   // Light
  static const Color _brightBlue = Color(0xFF3B82F6);  // Dark

  // Secondary / Soft Accent
  static const Color _iceBlue = Color(0xFFEBF2FF);     // Light
  static const Color _deepNavy = Color(0xFF172554);     // Dark

  // Scaffold Background
  static const Color _slate100 = Color(0xFFF1F5F9);    // Light
  static const Color _slate900 = Color(0xFF0F172A);     // Dark

  // Card / Surface
  static const Color _pureWhite = Color(0xFFFFFFFF);    // Light
  static const Color _slate800 = Color(0xFF1E293B);     // Dark

  // Inner Box / Subtle Fill
  static const Color _slate50 = Color(0xFFF8FAFC);      // Light
  static const Color _deepestSlate = Color(0xFF0B1120); // Dark

  // Primary Text
  static const Color _darkSlate = Color(0xFF1E293B);    // Light
  static const Color _offWhite = Color(0xFFF8FAFC);     // Dark

  // Secondary / Muted Text
  static const Color _slate500 = Color(0xFF64748B);     // Light
  static const Color _slate400 = Color(0xFF94A3B8);     // Dark

  // Borders & Dividers
  static const Color _slate200 = Color(0xFFE2E8F0);    // Light
  static const Color _slate700 = Color(0xFF334155);     // Dark

  // ── Light Theme ───────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    final base = ThemeData(
      brightness: Brightness.light,
      primaryColor: _royalBlue,
      scaffoldBackgroundColor: _slate100,
      dividerColor: _slate200,
      appBarTheme: const AppBarTheme(
        backgroundColor: _slate100,
        foregroundColor: _darkSlate,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _pureWhite,
        selectedItemColor: _royalBlue,
        unselectedItemColor: _slate500,
      ),
      dividerTheme: const DividerThemeData(
        color: _slate200,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _slate50,
        hintStyle: const TextStyle(color: _slate500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _royalBlue, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _royalBlue,
          foregroundColor: _pureWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: _royalBlue,
        secondary: _iceBlue,
        tertiary: _slate50,
        surface: _pureWhite,
        onSurface: _darkSlate,
        onPrimary: _pureWhite,
        outline: _slate200,
        surfaceContainerHighest: _pureWhite,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
        bodyColor: _darkSlate,
        displayColor: _darkSlate,
      ),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    final base = ThemeData(
      brightness: Brightness.dark,
      primaryColor: _brightBlue,
      scaffoldBackgroundColor: _slate900,
      dividerColor: _slate700,
      appBarTheme: const AppBarTheme(
        backgroundColor: _slate900,
        foregroundColor: _offWhite,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _slate800,
        selectedItemColor: _brightBlue,
        unselectedItemColor: _slate400,
      ),
      dividerTheme: const DividerThemeData(
        color: _slate700,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _deepestSlate,
        hintStyle: const TextStyle(color: _slate400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _slate700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _slate700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _brightBlue, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _brightBlue,
          foregroundColor: _offWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: _brightBlue,
        secondary: _deepNavy,
        tertiary: _deepestSlate,
        surface: _slate800,
        onSurface: _offWhite,
        onPrimary: _offWhite,
        outline: _slate700,
        surfaceContainerHighest: _slate800,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
        bodyColor: _offWhite,
        displayColor: _offWhite,
      ),
    );
  }
}
