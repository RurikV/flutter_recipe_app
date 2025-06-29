import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'navigation_bar_container.dart';
import 'nav_item.dart';

/// A stateless widget representing the custom bottom navigation bar.
class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
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
            isSelected: selectedIndex == 0,
            onTap: onItemTapped,
          ),

          // Favorites tab
          NavItem(
            index: 1,
            icon: Icons.favorite,
            label: l10n.favorites,
            isSelected: selectedIndex == 1,
            onTap: onItemTapped,
          ),

          // Profile tab
          NavItem(
            index: 2,
            icon: Icons.person,
            label: l10n.profile,
            isSelected: selectedIndex == 2,
            onTap: onItemTapped,
          ),
        ],
      ),
    );
  }
}
