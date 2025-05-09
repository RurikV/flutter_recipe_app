import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeList extends StatelessWidget {
  final List<Recipe> recipes;

  const RecipeList({
    Key? key,
    required this.recipes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCard(recipe: recipe);
      },
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              recipe.images,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 40),
                  ),
                );
              },
            ),
          ),
          
          // Recipe details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe name
                Text(
                  recipe.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8.0),
                
                // Recipe description
                Text(
                  recipe.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12.0),
                
                // Recipe metadata
                Row(
                  children: [
                    // Difficulty
                    _buildMetadataItem(
                      context,
                      Icons.signal_cellular_alt,
                      'Сложность: ${recipe.difficulty}/5',
                    ),
                    
                    const SizedBox(width: 16.0),
                    
                    // Rating
                    _buildMetadataItem(
                      context,
                      Icons.star,
                      'Рейтинг: ${recipe.rating}/5',
                    ),
                  ],
                ),
                
                const SizedBox(height: 12.0),
                
                // Tags
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: recipe.tags.map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(fontSize: 12.0),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.0,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 4.0),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}