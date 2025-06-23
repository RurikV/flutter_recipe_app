import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/comment.dart';
import '../services/recipe_manager.dart';
import '../widgets/recipe_header.dart';
import '../widgets/duration_display.dart';
import '../widgets/recipe_image.dart';
import '../widgets/ingredients_table.dart';
import '../widgets/recipe_steps_list.dart';
import '../widgets/cooking_mode_button.dart';
import '../widgets/comments_section.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeManager _recipeManager = RecipeManager();
  late Recipe _recipe;
  bool _isCookingMode = false;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  void _toggleFavorite() async {
    final success = await _recipeManager.toggleFavorite(_recipe.uuid);
    if (success && mounted) {
      setState(() {
        _recipe.isFavorite = !_recipe.isFavorite;
      });
    }
  }

  void _addComment(String commentText) async {
    if (commentText.isEmpty) return;

    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'User', // In a real app, this would be the current user's name
      text: commentText,
      date: DateTime.now().toString().substring(0, 10), // Format: YYYY-MM-DD
    );

    final success = await _recipeManager.addComment(_recipe.uuid, comment);
    if (success && mounted) {
      setState(() {
        // Update the local recipe object with the new comment
        final updatedComments = List<Comment>.from(_recipe.comments)..add(comment);
        _recipe = Recipe(
          uuid: _recipe.uuid,
          name: _recipe.name,
          images: _recipe.images,
          description: _recipe.description,
          instructions: _recipe.instructions,
          difficulty: _recipe.difficulty,
          duration: _recipe.duration,
          rating: _recipe.rating,
          tags: _recipe.tags,
          ingredients: _recipe.ingredients,
          steps: _recipe.steps,
          isFavorite: _recipe.isFavorite,
          comments: updatedComments,
        );
      });
    }
  }

  void _updateStepStatus(int index, bool isCompleted) async {
    final success = await _recipeManager.updateStepStatus(
      _recipe.uuid,
      index,
      isCompleted,
    );
    if (success && mounted) {
      setState(() {
        _recipe.steps[index].isCompleted = isCompleted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Рецепт'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality would go here
            },
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              width: orientation == Orientation.landscape
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe header with name and favorite button
                    RecipeHeader(
                      recipeName: _recipe.name,
                      isFavorite: _recipe.isFavorite,
                      onFavoriteToggle: _toggleFavorite,
                    ),

                    // Duration display
                    DurationDisplay(duration: _recipe.duration),

                    // Recipe image
                    RecipeImage(imageUrl: _recipe.images),

                    // Ingredients table
                    IngredientsTable(ingredients: _recipe.ingredients),

                    // Recipe steps list
                    RecipeStepsList(
                      steps: _recipe.steps,
                      isCookingMode: _isCookingMode,
                      recipeId: _recipe.uuid,
                      onStepStatusChanged: _updateStepStatus,
                    ),

                    // Cooking mode button
                    CookingModeButton(
                      isCookingMode: _isCookingMode,
                      onPressed: () {
                        setState(() {
                          _isCookingMode = !_isCookingMode;
                        });
                      },
                    ),

                    // Divider
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(
                        color: Color(0xFF797676),
                        thickness: 0.5,
                      ),
                    ),

                    // Comments section
                    CommentsSection(
                      comments: _recipe.comments,
                      onAddComment: _addComment,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
