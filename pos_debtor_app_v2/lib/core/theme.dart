import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Professional Financial Palette (Deep Blue & Gold/Amber variations)
  static const Color primaryColor = Color(0xFF1565C0); // Blue 800 - Trustworthy, Professional
  static const Color secondaryColor = Color(0xFF0288D1); // Light Blue 700
  static const Color accentColor = Color(0xFFFFC107); // Amber - Highlights/Attention
  
  static const Color errorColor = Color(0xFFC62828); // Red 800 - Clear error signal
  static const Color warningColor = Color(0xFFEF6C00); // Orange 800
  static const Color successColor = Color(0xFF2E7D32); // Green 800 - Financial positive
  
  static const Color backgroundLight = Color(0xFFF5F7FA); // Very light grey-blue tint
  static const Color surfaceLight = Colors.white;
  
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: surfaceLight,
        background: backgroundLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: Colors.black87, // High contrast text
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      
      // Text Theme - High Contrast
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
        displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black87),
        titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87),
        titleMedium: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        bodyLarge: GoogleFonts.outfit(fontSize: 16, color: Colors.black87), // Increased contrast
        bodyMedium: GoogleFonts.outfit(fontSize: 14, color: Colors.black87), // Increased contrast
        labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        labelStyle: GoogleFonts.outfit(fontSize: 16, color: Colors.grey.shade700),
        contentPadding: const EdgeInsets.all(16),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      
      iconTheme: const IconThemeData(color: primaryColor),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: const Color(0xFF42A5F5), // Lighter blue for dark mode visibility
        secondary: const Color(0xFF29B6F6),
        tertiary: accentColor,
        surface: surfaceDark,
        background: backgroundDark,
        error: const Color(0xFFEF5350),
      ),
      scaffoldBackgroundColor: backgroundDark,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70),
        bodyLarge: GoogleFonts.outfit(fontSize: 16, color: Colors.white70),
        bodyMedium: GoogleFonts.outfit(fontSize: 14, color: Colors.white60),
        labelLarge: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF42A5F5),
          foregroundColor: Colors.black, // Dark text on light button in dark mode
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        labelStyle: GoogleFonts.outfit(fontSize: 16, color: Colors.white60),
        contentPadding: const EdgeInsets.all(16),
      ),

      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 2,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      
      iconTheme: const IconThemeData(color: Colors.white70),
    );
  }
}
