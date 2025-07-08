import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/entities/recipe.dart' as domain;
import '../domain/entities/ingredient.dart';
import '../domain/entities/recipe_step.dart';
import '../domain/usecases/recipe_manager.dart';
import '../widgets/recipe/recipe_name_input.dart';
import '../widgets/recipe/photo_upload_section.dart';
import '../widgets/ingredient/ingredients_section.dart';
import '../widgets/step/steps_section.dart';
import '../widgets/recipe/save_recipe_button.dart';
import '../widgets/ingredient/ingredient_dialog.dart';
import '../widgets/step/step_dialog.dart';

class AddRecipeScreen extends StatefulWidget {
  final Function onRecipeAdded;

  const AddRecipeScreen({super.key, required this.onRecipeAdded});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // Using typed lists to ensure proper type handling
  final List<Ingredient> _ingredients = [];
  final List<RecipeStep> _steps = [];

  late final RecipeManager _recipeManager;

  List<String> _availableIngredients = [];
  List<String> _availableUnits = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _recipeManager = Provider.of<RecipeManager>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _availableIngredients = await _recipeManager.getIngredients();
      _availableUnits = await _recipeManager.getUnits();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки данных: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    showDialog(
      context: context,
      builder: (context) => IngredientDialog(
        availableIngredients: _availableIngredients,
        availableUnits: _availableUnits,
        onSave: (ingredient) {
          setState(() {
            _ingredients.add(ingredient);
          });
        },
      ),
    );
  }

  void _editIngredient(int index) {
    showDialog(
      context: context,
      builder: (context) => IngredientDialog(
        availableIngredients: _availableIngredients,
        availableUnits: _availableUnits,
        ingredient: _ingredients[index],
        onSave: (ingredient) {
          setState(() {
            _ingredients[index] = ingredient;
          });
        },
      ),
    );
  }

  void _addStep() {
    showDialog(
      context: context,
      builder: (context) => StepDialog(
        onSave: (entityStep) {
          setState(() {
            _steps.add(entityStep);
          });
        },
      ),
    );
  }

  void _editStep(int index) {
    showDialog(
      context: context,
      builder: (context) => StepDialog(
        step: _steps[index],
        onSave: (updatedEntityStep) {
          setState(() {
            _steps[index] = updatedEntityStep;
          });
        },
      ),
    );
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      if (_ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Добавьте хотя бы один ингредиент')),
        );
        return;
      }

      if (_steps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Добавьте хотя бы один шаг приготовления')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Use domain entities directly
        final List<Ingredient> typedIngredients = List<Ingredient>.from(_ingredients);
        final List<RecipeStep> typedSteps = List<RecipeStep>.from(_steps);

        // Create a new recipe with the current data
        final recipe = domain.Recipe(
          uuid: DateTime.now().millisecondsSinceEpoch.toString(), // Generate a unique ID
          name: _nameController.text,
          images: _imageUrlController.text.isEmpty 
              ? 'https://placehold.co/400x300/png?text=No+Image' 
              : _imageUrlController.text,
          description: _descriptionController.text,
          instructions: '', // This field is not used in the new model
          difficulty: 2, // Default difficulty
          duration: _durationController.text,
          rating: 0, // Default rating
          tags: [], // Default empty tags
          ingredients: typedIngredients,
          steps: typedSteps,
        );

        final success = await _recipeManager.saveRecipe(recipe);

        if (success) {
          widget.onRecipeAdded();
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ошибка при сохранении рецепта')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Новый рецепт',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 20,
            color: Color(0xFF165932),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: const Color.fromRGBO(0, 0, 0, 0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.black,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : OrientationBuilder(
              builder: (context, orientation) {
                return Center(
                  child: SizedBox(
                    width: orientation == Orientation.landscape
                        ? MediaQuery.of(context).size.width * 0.5
                        : MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Recipe name input field
                            RecipeNameInput(controller: _nameController),

                            // Photo upload section
                            PhotoUploadSection(controller: _imageUrlController),

                            // Ingredients section
                            IngredientsSection(
                              ingredients: List<Ingredient>.from(_ingredients),
                              onAddIngredient: _addIngredient,
                              onEditIngredient: _editIngredient,
                              onRemoveIngredient: _removeIngredient,
                            ),

                            // Steps section
                            StepsSection(
                              steps: _steps,
                              onAddStep: _addStep,
                              onEditStep: _editStep,
                              onRemoveStep: _removeStep,
                            ),

                            // Save recipe button
                            SaveRecipeButton(onPressed: _saveRecipe),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
