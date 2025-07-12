import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import '../data/models/recipe.dart';
import '../data/models/comment.dart' as data_model;
import '../data/models/recipe_step.dart';
import '../data/usecases/recipe_manager.dart';
import '../services/classification/object_detection_service.dart';
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
  bool _isLoading = true;
  ObjectDetectionService? _objectDetectionService;


  @override
  void initState() {
    super.initState();
    _recipeManager = Provider.of<RecipeManager>(context, listen: false);
    try {
      _objectDetectionService = Provider.of<ObjectDetectionService>(context, listen: false);
    } catch (e) {
      // If ObjectDetectionService is not available in Provider, it will be obtained by RecipeImageGallery
      _objectDetectionService = null;
    }
    _recipe = widget.recipe;
    _loadRecipeDetails();
  }

  Future<void> _loadRecipeDetails() async {
    print('[DEBUG_LOG] RecipeDetailScreen: Starting to load recipe details for UUID: ${_recipe.uuid}');
    print('[DEBUG_LOG] RecipeDetailScreen: Initial recipe data:');
    print('[DEBUG_LOG] - Name: ${_recipe.name}');
    print('[DEBUG_LOG] - Ingredients count: ${_recipe.ingredients.length}');
    print('[DEBUG_LOG] - Steps count: ${_recipe.steps.length}');

    try {
      print('[DEBUG_LOG] RecipeDetailScreen: Calling _recipeManager.getRecipeByUuid(${_recipe.uuid})');

      // Fetch detailed recipe information from the API
      final detailedRecipe = await _recipeManager.getRecipeByUuid(_recipe.uuid);

      print('[DEBUG_LOG] RecipeDetailScreen: API call completed');

      if (detailedRecipe != null) {
        print('[DEBUG_LOG] RecipeDetailScreen: Detailed recipe received:');
        print('[DEBUG_LOG] - UUID: ${detailedRecipe.uuid}');
        print('[DEBUG_LOG] - Name: ${detailedRecipe.name}');
        print('[DEBUG_LOG] - Duration: ${detailedRecipe.duration}');
        print('[DEBUG_LOG] - Ingredients count: ${detailedRecipe.ingredients.length}');
        print('[DEBUG_LOG] - Steps count: ${detailedRecipe.steps.length}');

        if (detailedRecipe.ingredients.isNotEmpty) {
          print('[DEBUG_LOG] RecipeDetailScreen: Ingredients details:');
          for (int i = 0; i < detailedRecipe.ingredients.length; i++) {
            final ingredient = detailedRecipe.ingredients[i];
            print('[DEBUG_LOG]   ${i + 1}. ${ingredient.name} - ${ingredient.quantity} ${ingredient.unit}');
          }
        } else {
          print('[DEBUG_LOG] RecipeDetailScreen: ⚠️ NO INGREDIENTS FOUND in detailed recipe!');
        }

        if (detailedRecipe.steps.isNotEmpty) {
          print('[DEBUG_LOG] RecipeDetailScreen: Steps details:');
          for (int i = 0; i < detailedRecipe.steps.length; i++) {
            final step = detailedRecipe.steps[i];
            print('[DEBUG_LOG]   ${i + 1}. ${step.name} (${step.duration} min)');
          }
        } else {
          print('[DEBUG_LOG] RecipeDetailScreen: ⚠️ NO STEPS FOUND in detailed recipe!');
        }

        if (mounted) {
          print('[DEBUG_LOG] RecipeDetailScreen: Updating state with detailed recipe');
          setState(() {
            _recipe = detailedRecipe;
            _isLoading = false;
          });
          print('[DEBUG_LOG] RecipeDetailScreen: State updated successfully');
        } else {
          print('[DEBUG_LOG] RecipeDetailScreen: Widget not mounted, skipping state update');
        }
      } else {
        print('[DEBUG_LOG] RecipeDetailScreen: ❌ Detailed recipe is NULL!');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('[DEBUG_LOG] RecipeDetailScreen: ❌ Error loading recipe details: $e');
      print('[DEBUG_LOG] RecipeDetailScreen: Error stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleFavorite() {
    // Get the store from the StoreProvider
    final store = StoreProvider.of<AppState>(context);
    // Dispatch the toggle favorite action to the Redux store
    store.dispatch(ToggleFavoriteAction(_recipe.uuid));
  }

  void _addComment(String commentText) async {
    if (commentText.isEmpty) return;

    final commentId = DateTime.now().millisecondsSinceEpoch.toString();
    final commentDate = DateTime.now().toString().substring(0, 10); // Format: YYYY-MM-DD

    // Create model Comment for RecipeManager
    final modelComment = data_model.Comment(
      id: commentId,
      authorName: 'User', // In a real app, this would be the current user's name
      text: commentText,
      date: commentDate,
    );

    final success = await _recipeManager.addComment(_recipe.uuid, modelComment);
    if (success && mounted) {
      setState(() {
        // Update the local recipe object with the new comment
        final updatedComments = List<data_model.Comment>.from(_recipe.comments)..add(modelComment);
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
                    objectDetectionService: _objectDetectionService!,
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : OrientationBuilder(
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
                      objectDetectionService: _objectDetectionService,
                    ),

                    // Ingredients table
                    IngredientsTable(
                      ingredients: _recipe.ingredients,
                    ),

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
