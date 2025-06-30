import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/database/app_database.dart';
import 'package:flutter_recipe_app/service_locator.dart' as serviceLocator;

/// This example demonstrates how to use the cross-platform database implementation
/// with the service locator pattern.
class DatabaseUsageExample extends StatefulWidget {
  const DatabaseUsageExample({Key? key}) : super(key: key);

  @override
  State<DatabaseUsageExample> createState() => _DatabaseUsageExampleState();
}

class _DatabaseUsageExampleState extends State<DatabaseUsageExample> {
  late AppDatabase _database;
  List<Recipe> _recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  /// Initialize the database using the service locator
  Future<void> _initializeDatabase() async {
    // Initialize the service locator (this should typically be done in main.dart)
    await AppDatabase.initialize();
    
    // Get the database instance from the service locator
    _database = AppDatabase.getInstance();
    
    // Load recipes
    await _loadRecipes();
  }

  /// Load recipes from the database
  Future<void> _loadRecipes() async {
    try {
      final recipes = await _database.getAllRecipes();
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Usage Example'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recipes.isEmpty
              ? const Center(child: Text('No recipes found'))
              : ListView.builder(
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    return ListTile(
                      title: Text(recipe.title),
                      subtitle: Text(recipe.description ?? 'No description'),
                      trailing: recipe.isFavorite
                          ? const Icon(Icons.favorite, color: Colors.red)
                          : const Icon(Icons.favorite_border),
                      onTap: () {
                        // Example of toggling favorite status
                        if (recipe.isFavorite) {
                          _database.removeFromFavorites(recipe.uuid);
                        } else {
                          _database.addToFavorites(recipe.uuid);
                        }
                        _loadRecipes(); // Reload to reflect changes
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadRecipes,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

/// How to use this in your app:
/// 
/// 1. Initialize the database in your main.dart:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await AppDatabase.initialize();
///   runApp(MyApp());
/// }
/// ```
/// 
/// 2. Get the database instance in your widgets:
/// ```dart
/// final database = AppDatabase.getInstance();
/// ```
/// 
/// 3. Use the database instance to perform operations:
/// ```dart
/// final recipes = await database.getAllRecipes();
/// ```