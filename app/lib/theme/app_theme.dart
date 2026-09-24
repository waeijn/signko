import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class AppTheme {
  // Dribbble-style Blue Palette (Minimalist Application)
  static const Color _deepBlue = Color(0xFF4C5BF7); // Keeping the true indigo
  static const Color _primaryBlue =
      Color(0xFF2962FF); // Solid blue for active states
  static const Color _accentCyan = Color(0xFF42E8E0);
  static const Color _iceBlue = Color(0xFFF4F7FE); // Pale background
  static const Color _darkNavy = Color(0xFF141A31); // Dark mode background
  static const Color _darkNavyCard = Color(0xFF1F2642); // Dark mode card

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: _deepBlue,
      scaffoldBackgroundColor: _iceBlue,
      appBarTheme: const AppBarTheme(
        backgroundColor: _iceBlue,
        foregroundColor: _darkNavy,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _deepBlue,
        unselectedItemColor: Colors.black38,
      ),
      colorScheme: const ColorScheme.light(
        primary: _primaryBlue, // Active elements use classic blue
        secondary: _deepBlue, // Secondary uses indigo
        tertiary: _accentCyan, // Toggles/minor accents use cyan
        surface: Colors.white,
        onSurface: _darkNavy,
        surfaceContainerHighest: Colors.white, // White cards on ice blue bg
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: _accentCyan,
      scaffoldBackgroundColor: _darkNavy,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkNavyCard,
        selectedItemColor: _accentCyan,
        unselectedItemColor: Colors.white54,
      ),
      colorScheme: const ColorScheme.dark(
        primary: _accentCyan,
        secondary: _primaryBlue,
        tertiary: _deepBlue,
        surface: _darkNavyCard,
        onSurface: Colors.white,
        surfaceContainerHighest:
            Color(0xFF2A3357), // Slightly lighter dark navy for cards
      ),
    );
  }
}
