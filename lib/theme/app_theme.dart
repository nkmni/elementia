import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgDark = Color(0xFF0F172A);
  static const Color accentPrimary = Color(0xFF38BDF8); // Cyan
  static const Color accentSecondary = Color(0xFF818CF8); // Indigo
  static const Color accentTertiary = Color(0xFFC084FC); // Purple
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: accentPrimary,
      secondary: accentSecondary,
      tertiary: accentTertiary,
      background: bgDark,
    ),
  );
}
