import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Designer Palette
  static const Color primaryOrange = Color(0xFFF3680B);
  static const Color secondaryBlue = Color(0xFF4D9DB8);
  static const Color lightOrange = Color(0xFFF89C45);
  static const Color paleBlue = Color(0xFFB4D5DE);

  // Light Mode Background
  static const Color creamBackground = Color(0xFFFFFEEC);
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color mediumText = Color(0xFF4A4A4A);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: creamBackground,
    primaryColor: primaryOrange,
    colorScheme: const ColorScheme.light(
      primary: primaryOrange,
      secondary: secondaryBlue,
      tertiary: lightOrange,
      surface: creamBackground,
      error: Color(0xFFFF0055),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkText,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.nunito(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: darkText,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: darkText,
      ),
      displaySmall: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkText,
      ),
      bodyLarge: GoogleFonts.nunito(fontSize: 16, color: darkText),
      bodyMedium: GoogleFonts.nunito(fontSize: 14, color: darkText),
    ),
    useMaterial3: true,
  );
}
