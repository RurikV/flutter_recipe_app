import 'package:flutter/material.dart';
import '../screens/recipe_list_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/profile_screen.dart';

/// A stateless widget representing the content of the home screen.
class HomeScreenContent extends StatelessWidget {
  final int selectedIndex;

  const HomeScreenContent({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    // List of screens to display
    final List<Widget> screens = [
      const RecipeListScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];

    return screens[selectedIndex];
  }
}