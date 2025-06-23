import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_manager.dart';
import '../widgets/recipe_list.dart';
import 'add_recipe_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final RecipeManager _recipeManager = RecipeManager();
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    setState(() {
      _recipesFuture = _recipeManager.getRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECECEC), // Background color as per design
      appBar: AppBar(
        title: const Text('Рецепты'),
        centerTitle: true,
        backgroundColor: const Color(0xFFECECEC), // Match background color
        elevation: 0, // No shadow
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecipeScreen(
                onRecipeAdded: _loadRecipes,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF2ECC71),
        child: const Icon(Icons.add),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              width: orientation == Orientation.landscape
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width,
              child: FutureBuilder<List<Recipe>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки рецептов',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.no_food,
                    color: Colors.grey,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет доступных рецептов',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          } else {
            return RecipeList(recipes: snapshot.data!);
          }
        },
              ),
            ),
          );
        },
      ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recipes tab
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_pizza, // Pizza icon as per design
                    color: const Color(0xFF2ECC71), // Green color for active tab
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Рецепты',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF2ECC71), // Green color for active tab
                    ),
                  ),
                ],
              ),
            ),

            // Login tab
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person, // Person icon as per design
                    color: const Color(0xFFC2C2C2), // Gray color for inactive tab
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Вход',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFC2C2C2), // Gray color for inactive tab
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
