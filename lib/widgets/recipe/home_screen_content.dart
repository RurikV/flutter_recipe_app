import 'package:flutter/material.dart';
import '../../screens/recipe_list_screen.dart';
import '../../screens/favorites_screen.dart';
import '../../screens/profile_screen.dart';

/// A stateless widget representing the content of the home screen.
class HomeScreenContent extends StatelessWidget {
  final int selectedIndex;

  const HomeScreenContent({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Create new instances of screens each time to ensure proper state initialization
    Widget currentScreen;

    switch (selectedIndex) {
      case 0:
        currentScreen = RecipeListScreen();
        break;
      case 1:
        currentScreen = FavoritesScreen();
        break;
      case 2:
        currentScreen = ProfileScreen();
        break;
      default:
        currentScreen = RecipeListScreen();
    }

    return currentScreen;
  }
}
