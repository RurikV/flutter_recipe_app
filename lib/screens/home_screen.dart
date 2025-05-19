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
      bottomNavigationBar: Container(
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
            _buildNavItem(0, Icons.local_pizza, 'Рецепты'),
            
            // Favorites tab
            _buildNavItem(1, Icons.favorite, 'Избранное'),
            
            // Profile tab
            _buildNavItem(2, Icons.person, 'Профиль'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _selectedIndex == index;
    final Color color = isSelected ? const Color(0xFF2ECC71) : const Color(0xFFC2C2C2);
    
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
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