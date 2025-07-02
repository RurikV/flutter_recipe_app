import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'navigation_bar_container.dart';
import 'nav_item.dart';
import '../../screens/recipe_list_screen.dart';

/// A stateless widget representing the bottom navigation bar for authentication screens.
class AuthBottomNavigationBar extends StatelessWidget {
  final bool isLoginActive;

  const AuthBottomNavigationBar({
    super.key,
    this.isLoginActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NavigationBarContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Recipes tab
          NavItem(
            index: 0,
            icon: Icons.local_pizza,
            label: l10n.recipes,
            isSelected: !isLoginActive,
            onTap: (index) {
              // Navigate to RecipeListScreen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => RecipeListScreen()),
              );
            },
          ),

          // Login tab
          NavItem(
            index: 1,
            icon: Icons.person,
            label: 'Вход',
            isSelected: isLoginActive,
            onTap: (index) {
              // Do nothing if already on login screen
              if (!isLoginActive) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}