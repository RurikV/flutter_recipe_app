import 'package:flutter/material.dart';
import 'recipe_list_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens to display
  final List<Widget> _screens = [
    const RecipeListScreen(),
    const FavoritesScreen(),
    const Scaffold(body: Center(child: Text('Профиль'))), // Placeholder for profile screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

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
    return Container(
      height: 60, // Height as per design
      decoration: const BoxDecoration(
        color: Colors.white, // White background as per design
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25), // Shadow as per design
            blurRadius: 8,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Recipes tab
          NavItem(
            index: 0,
            icon: Icons.local_pizza,
            label: 'Рецепты',
            isSelected: selectedIndex == 0,
            onTap: onItemTapped,
          ),

          // Favorites tab
          NavItem(
            index: 1,
            icon: Icons.favorite,
            label: 'Избранное',
            isSelected: selectedIndex == 1,
            onTap: onItemTapped,
          ),

          // Profile tab
          NavItem(
            index: 2,
            icon: Icons.person,
            label: 'Профиль',
            isSelected: selectedIndex == 2,
            onTap: onItemTapped,
          ),
        ],
      ),
    );
  }
}

/// A stateless widget representing a navigation item in the bottom navigation bar.
class NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;
  final Function(int) onTap;

  const NavItem({
    super.key,
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected ? const Color(0xFF2ECC71) : const Color(0xFFC2C2C2);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
