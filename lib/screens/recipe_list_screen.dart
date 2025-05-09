import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_manager.dart';
import '../widgets/recipe_list.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({Key? key}) : super(key: key);

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final RecipeManager _recipeManager = RecipeManager();
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = _recipeManager.getRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рецепты'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Recipe>>(
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
    );
  }
}