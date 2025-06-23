import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      fontFamily: 'Roboto', // Use Roboto font as per design
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2ECC71), // Green primary color as per design
        primary: const Color(0xFF2ECC71),
        secondary: const Color(0xFFFF9800), // Orange accent color
        surface: const Color(0xFFECECEC), // Background color as per design
      ),
      scaffoldBackgroundColor: const Color(0xFFECECEC), // Background color as per design
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFECECEC), // Match background color
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: const Color.fromRGBO(149, 146, 146, 0.1), // Shadow color as per design
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // 5px border radius as per design
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE8F5E9), // Light green background
        labelStyle: const TextStyle(color: Color(0xFF2E7D32)), // Dark green text
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 22, // 22px as per design
          fontWeight: FontWeight.w500, // Medium weight as per design
          color: Colors.black,
          height: 1.0, // Line height as per design
        ),
        titleMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF424242),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: Color(0xFF616161),
        ),
        bodySmall: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          color: Color(0xFF757575),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF2ECC71), // Green color for icons as per design
      ),
    );
  }
}