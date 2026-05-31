import 'package:flutter/material.dart';

abstract final class AppTypography {
  AppTypography._();

  static const String arabicFont = 'Cairo';
  static const String englishFont = 'Poppins';

  static String fontFamily(bool isArabic) => isArabic ? arabicFont : englishFont;

  static TextTheme textTheme(bool isArabic) {
    final font = fontFamily(isArabic);
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: font,
        fontSize: 57,
        fontWeight: FontWeight.w700,
        height: 1.12,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        fontFamily: font,
        fontSize: 45,
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
      displaySmall: TextStyle(
        fontFamily: font,
        fontSize: 36,
        fontWeight: FontWeight.w600,
        height: 1.22,
      ),
      headlineLarge: TextStyle(
        fontFamily: font,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontFamily: font,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontFamily: font,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
      ),
      titleLarge: TextStyle(
        fontFamily: font,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontFamily: font,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.50,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontFamily: font,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.10,
      ),
      bodyLarge: TextStyle(
        fontFamily: font,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.50,
        letterSpacing: 0.50,
      ),
      bodyMedium: TextStyle(
        fontFamily: font,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontFamily: font,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.40,
      ),
      labelLarge: TextStyle(
        fontFamily: font,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.10,
      ),
      labelMedium: TextStyle(
        fontFamily: font,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.50,
      ),
      labelSmall: TextStyle(
        fontFamily: font,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.50,
      ),
    );
  }
}
