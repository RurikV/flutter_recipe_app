import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

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
        // Use AppTheme's base theme
        colorScheme: AppTheme.theme.colorScheme,
        textTheme: AppTheme.theme.textTheme,
        // Add custom page transitions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            // Use FadeUpwardsPageTransitionsBuilder for all platforms
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
