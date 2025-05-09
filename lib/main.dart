import 'package:flutter/material.dart';
import 'screens/recipe_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Рецепты',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // Green primary color
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFFFF9800), // Orange accent color
          background: Colors.white,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF424242),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF616161),
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Color(0xFF757575),
          ),
        ),
      ),
      home: const RecipeListScreen(),
    );
  }
}
