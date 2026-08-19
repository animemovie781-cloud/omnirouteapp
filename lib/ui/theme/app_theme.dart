import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryAccent = Color(0xFF00E5FF); // Cyber Cyan / Antigravity Accent
  static const Color secondaryAccent = Color(0xFF7C4DFF); // Deep Purple
  static const Color bgDark = Color(0xFF0E1117); // IDE Background
  static const Color cardDark = Color(0xFF161B22); // Card / Panel Background
  static const Color sidebarDark = Color(0xFF090C10); // Sidebar Background
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color borderDark = Color(0xFF30363D);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryAccent,
      cardColor: cardDark,
      canvasColor: sidebarDark,
      dividerColor: borderDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        secondary: secondaryAccent,
        surface: cardDark,
        background: bgDark,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: sidebarDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryAccent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textSecondary),
      ),
    );
  }
}
