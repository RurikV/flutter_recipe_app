import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      fontFamily: 'Roboto', // Use Roboto font as per design
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen, // Green primary color as per design
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryOrange, // Orange accent color
        surface: AppColors.background, // Background color as per design
      ),
      scaffoldBackgroundColor: AppColors.background, // Background color as per design
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background, // Match background color
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: AppColors.shadowColor, // Shadow color as per design
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // 5px border radius as per design
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.chipBackground, // Light green background
        labelStyle: TextStyle(color: AppColors.chipText), // Dark green text
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 22, // 22px as per design
          fontWeight: FontWeight.w500, // Medium weight as per design
          color: AppColors.textPrimary,
          height: 1.0, // Line height as per design
        ),
        titleMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: AppColors.textTertiary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          color: AppColors.textQuaternary,
        ),
      ),
      iconTheme: IconThemeData(
        color: AppColors.iconPrimary, // Green color for icons as per design
      ),
    );
  }
}
