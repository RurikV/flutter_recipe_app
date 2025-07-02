import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../models/comment.dart';
import '../../models/recipe_step.dart';
import '../domain/usecases/recipe_manager.dart';
import '../utils/entity_converters.dart';
import '../widgets/recipe/recipe_header.dart';
import '../widgets/recipe/duration_display.dart';
import '../widgets/recipe/recipe_image_gallery.dart';
import '../widgets/ingredient/ingredients_table.dart';
import '../widgets/step/recipe_steps_list.dart';
import '../widgets/recipe/cooking_mode_button.dart';
import '../widgets/comment/comments_section.dart';
import '../screens/gallery_screen.dart';
import '../utils/page_transitions.dart';
import '../redux/app_state.dart';
import '../redux/actions.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late final RecipeManager _recipeManager;
  late Recipe _recipe;
  bool _isCookingMode = false;


  @override
  void initState() {
    super.initState();
    _recipeManager = Provider.of<RecipeManager>(context, listen: false);
    _recipe = widget.recipe;
  }

  void _toggleFavorite() {
    // Get the store from the StoreProvider
    final store = StoreProvider.of<AppState>(context);
    // Dispatch the toggle favorite action to the Redux store
    store.dispatch(ToggleFavoriteAction(_recipe.uuid));
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
        _recipe = _recipe.copyWith(comments: updatedComments);
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
        // Create a copy of the steps list and cast it to the correct type
        final updatedSteps = List.from(_recipe.steps).cast<RecipeStep>();
        // Update the step at the specified index
        updatedSteps[index] = updatedSteps[index].copyWith(isCompleted: isCompleted);
        // Update the recipe with the new steps list
        _recipe = _recipe.copyWith(steps: updatedSteps);
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
            icon: const Icon(Icons.photo_library),
            tooltip: 'Photo Gallery',
            onPressed: () {
              Navigator.of(context).push(
                SlideRightPageRoute(
                  widget: GalleryScreen(
                    recipeUuid: _recipe.uuid,
                    recipeName: _recipe.name,
                  ),
                ),
              );
            },
          ),
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
            child: SizedBox(
              width: orientation == Orientation.landscape
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe header with name and favorite button
                    StoreConnector<AppState, bool>(
                      converter: (store) {
                        // Find the recipe in the Redux store
                        final storeRecipe = store.state.recipes.firstWhere(
                          (r) => r.uuid == _recipe.uuid,
                          orElse: () => _recipe,
                        );
                        return storeRecipe.isFavorite;
                      },
                      builder: (context, isFavorite) {
                        return RecipeHeader(
                          recipeName: _recipe.name,
                          isFavorite: isFavorite,
                          onFavoriteToggle: _toggleFavorite,
                        );
                      },
                    ),

                    // Duration display
                    DurationDisplay(duration: _recipe.duration),

                    // Recipe image gallery
                    RecipeImageGallery(
                      images: _recipe.images,
                      onImagesChanged: (updatedImages) {
                        setState(() {
                          // Update the recipe with the new images
                          _recipe = _recipe.copyWith(images: updatedImages);
                        });
                      },
                    ),

                    // Ingredients table
                    IngredientsTable(
                      ingredients: EntityConverters.modelToEntityIngredients(_recipe.ingredients),
                    ),

                    // Recipe steps list
                    RecipeStepsList(
                      steps: EntityConverters.modelToEntityRecipeSteps(_recipe.steps),
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
