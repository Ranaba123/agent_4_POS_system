import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00796B); // Teal 700
  static const Color secondaryColor = Color(0xFFB2DFDB); // Teal 100
  static const Color errorColor = Color(0xFFD32F2F); // Red 700
  static const Color warningColor = Color(0xFFFFA000); // Amber 700
  static const Color successColor = Color(0xFF388E3C); // Green 700
  
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: background,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      
      // Text Theme - Large and Readable
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
        displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black87),
        titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87),
        titleMedium: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87), // Fix missing
        bodyLarge: GoogleFonts.outfit(fontSize: 18, color: Colors.black87),
        bodyMedium: GoogleFonts.outfit(fontSize: 16, color: Colors.black54),
        labelLarge: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
      ),

      // Button Theme - Large and Accessible
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: GoogleFonts.outfit(fontSize: 16, color: Colors.black54),
        contentPadding: const EdgeInsets.all(16),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: const Color(0xFF004D40),
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: GoogleFonts.outfit(fontSize: 18, color: Colors.white70),
        bodyMedium: GoogleFonts.outfit(fontSize: 16, color: Colors.white60),
        labelLarge: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: GoogleFonts.outfit(fontSize: 16, color: Colors.white60),
        contentPadding: const EdgeInsets.all(16),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      
      iconTheme: const IconThemeData(color: Colors.white70),
    );
  }
}
