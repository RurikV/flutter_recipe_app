import 'package:flutter/material.dart';
import '../../../data/models/recipe.dart';
import 'recipe_card.dart';

class RecipeList extends StatelessWidget {
  final List<Recipe> recipes;

  const RecipeList({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        // Calculate top position based on index (80px for first card, then 160px increments)
        // This is just for visual reference, as ListView will handle actual positioning
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: RecipeCard(recipe: recipe),
        );
      },
    );
  }
}
