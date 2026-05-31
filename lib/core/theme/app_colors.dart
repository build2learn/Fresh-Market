import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Brand
  static const Color brandGreen = Color(0xFF2E7D32);
  static const Color brandGreenLight = Color(0xFF4CAF50);
  static const Color brandGreenDark = Color(0xFF1B5E20);
  static const Color brandGreenBg = Color(0xFFE8F5E9);

  static const Color brandOrange = Color(0xFFFF6F00);
  static const Color brandOrangeLight = Color(0xFFFFB74D);

  static const Color brandBlue = Color(0xFF1565C0);
  static const Color brandBlueLight = Color(0xFFBBDEFB);

  // Neutral
  static const Color neutral900 = Color(0xFF212121);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral50 = Color(0xFFFAFAFA);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1565C0);

  static const Color successBg = Color(0xFFE8F5E9);
  static const Color warningBg = Color(0xFFFFF3E0);
  static const Color errorBg = Color(0xFFFFEBEE);
  static const Color infoBg = Color(0xFFE3F2FD);

  // Dark mode surfaces
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkBackground = Color(0xFF121212);
}
