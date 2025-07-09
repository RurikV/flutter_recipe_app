import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../widgets/recipe/home_screen_content.dart';
import '../widgets/navigation/custom_bottom_navigation_bar.dart';
import '../redux/app_state.dart';
import '../redux/actions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // Load recipes when the app starts (favorites will be loaded automatically after recipes complete)
    // Capture the store before the async operation to avoid using BuildContext across async gaps
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final store = StoreProvider.of<AppState>(context, listen: false);
        store.dispatch(LoadRecipesAction());
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Dispatch LoadRecipesAction to refresh data (favorites will be loaded automatically after recipes complete)
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(LoadRecipesAction());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeScreenContent(selectedIndex: _selectedIndex),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
