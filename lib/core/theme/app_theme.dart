import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_dimensions.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData light({required bool isArabic}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.brandGreen,
        onPrimary: Colors.white,
        primaryContainer: AppColors.brandGreenLight,
        onPrimaryContainer: AppColors.brandGreenDark,
        secondary: AppColors.brandOrange,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.brandOrangeLight,
        tertiary: AppColors.brandBlue,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.brandBlueLight,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorBg,
        surface: Colors.white,
        onSurface: AppColors.neutral900,
        surfaceContainerHighest: AppColors.neutral100,
        outline: AppColors.neutral400,
      ),
      textTheme: AppTypography.textTheme(isArabic),
      cardTheme: CardTheme(
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.lg,
            vertical: AppDimensions.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTypography.textTheme(isArabic).labelLarge,
          elevation: AppDimensions.elevationNone,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandGreen,
          side: const BorderSide(color: AppColors.brandGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.lg,
            vertical: AppDimensions.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTypography.textTheme(isArabic).labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandGreen,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sm,
            vertical: AppDimensions.sm,
          ),
          textStyle: AppTypography.textTheme(isArabic).labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.neutral400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.neutral400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.brandGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.neutral600),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.brandGreen,
        unselectedItemColor: AppColors.neutral600,
        type: BottomNavigationBarType.fixed,
        elevation: AppDimensions.elevationLg,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral100,
        selectedColor: AppColors.brandGreenBg,
        labelStyle: AppTypography.textTheme(isArabic).labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm,
          vertical: AppDimensions.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          side: const BorderSide(color: AppColors.neutral400),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral900,
        contentTextStyle: AppTypography.textTheme(isArabic).bodyMedium?.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.neutral900,
        elevation: AppDimensions.elevationNone,
        centerTitle: isArabic,
        titleTextStyle: AppTypography.textTheme(isArabic).titleLarge?.copyWith(
          color: AppColors.neutral900,
        ),
      ),
    );
  }

  static ThemeData dark({required bool isArabic}) {
    final lightTheme = light(isArabic: isArabic);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: lightTheme.colorScheme.copyWith(
        brightness: Brightness.dark,
        surface: AppColors.darkSurface,
        onSurface: AppColors.neutral50,
        surfaceContainerHighest: AppColors.darkCard,
      ),
      textTheme: AppTypography.textTheme(isArabic),
      scaffoldBackgroundColor: AppColors.darkBackground,
    );
  }
}
