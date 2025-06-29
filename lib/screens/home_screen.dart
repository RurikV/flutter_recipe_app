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

    // Load both recipes and favorites when the app starts
    Future.microtask(() {
      final store = StoreProvider.of<AppState>(context, listen: false);
      store.dispatch(LoadRecipesAction());
      store.dispatch(LoadFavoriteRecipesAction());
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Always dispatch both actions to ensure both recipes and favorites are loaded
    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(LoadRecipesAction());
    store.dispatch(LoadFavoriteRecipesAction());
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
