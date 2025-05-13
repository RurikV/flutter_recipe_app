import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/recipe_step.dart';
import '../services/recipe_manager.dart';

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

  final List<Ingredient> _ingredients = [];
  final List<RecipeStep> _steps = [];

  final RecipeManager _recipeManager = RecipeManager();

  List<String> _availableIngredients = [];
  List<String> _availableUnits = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      builder: (context) => _IngredientDialog(
        availableIngredients: _availableIngredients,
        availableUnits: _availableUnits,
        onAdd: (ingredient) {
          setState(() {
            _ingredients.add(ingredient);
          });
        },
      ),
    );
  }

  void _addStep() {
    showDialog(
      context: context,
      builder: (context) => _StepDialog(
        onAdd: (step) {
          setState(() {
            _steps.add(step);
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
        final recipe = Recipe(
          uuid: DateTime.now().millisecondsSinceEpoch.toString(), // Generate a unique ID
          name: _nameController.text,
          images: _imageUrlController.text.isEmpty 
              ? 'https://via.placeholder.com/400x300?text=No+Image' 
              : _imageUrlController.text,
          description: _descriptionController.text,
          instructions: '', // This field is not used in the new model
          difficulty: 2, // Default difficulty
          duration: _durationController.text,
          rating: 0, // Default rating
          tags: [], // Default empty tags
          ingredients: _ingredients,
          steps: _steps,
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
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe name input field
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 112),
                      child: Stack(
                        children: [
                          Container(
                            width: 396,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Color(0xFFECECEC),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(2),
                                topRight: Radius.circular(2),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 36.31,
                            top: 120.17 - 112,
                            child: const Text(
                              'Название рецепта',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                fontSize: 10,
                                color: Color(0xFF165932),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            top: 168 - 112,
                            child: Container(
                              width: 396,
                              height: 0,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF165932),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 36.31,
                            top: 135,
                            right: 16,
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите название рецепта';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Photo upload section
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 17),
                      child: Container(
                        width: 396,
                        height: 215,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECECEC),
                          border: Border.all(
                            color: const Color(0xFF165932),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Color(0xFF165932),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Добавить фото рецепта',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xFF165932),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Hidden field for image URL
                            Opacity(
                              opacity: 0,
                              child: TextFormField(
                                controller: _imageUrlController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Ingredients section
                    Padding(
                      padding: const EdgeInsets.only(left: 17, top: 19),
                      child: Text(
                        'Ингредиенты',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 23/16,
                          color: const Color(0xFF165932),
                        ),
                      ),
                    ),

                    // Ingredients list or placeholder
                    if (_ingredients.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 9),
                        child: Center(
                          child: Text(
                            'нет ингредиентов',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 23/12,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _ingredients.length,
                          itemBuilder: (context, index) {
                            final ingredient = _ingredients[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text(
                                  ingredient.name,
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  '${ingredient.quantity} ${ingredient.unit}',
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Color(0xFF797676),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _removeIngredient(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Add ingredient button
                    Padding(
                      padding: const EdgeInsets.only(left: 97, top: 25),
                      child: SizedBox(
                        width: 232,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _addIngredient,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF165932), width: 3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Добавить ингредиент',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color(0xFF165932),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Steps section
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 42),
                      child: Text(
                        'Шаги приготовления',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 23/16,
                          color: const Color(0xFF165932),
                        ),
                      ),
                    ),

                    // Steps list or placeholder
                    if (_steps.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Center(
                          child: Text(
                            'нет шагов приготовления',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 23/12,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _steps.length,
                          itemBuilder: (context, index) {
                            final step = _steps[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                leading: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24,
                                    color: Color(0xFFC2C2C2),
                                  ),
                                ),
                                title: Text(
                                  step.description,
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Color(0xFF797676),
                                  ),
                                ),
                                subtitle: Text(
                                  'Время: ${step.duration}',
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xFF797676),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _removeStep(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Add step button
                    Padding(
                      padding: const EdgeInsets.only(left: 100, top: 25),
                      child: SizedBox(
                        width: 232,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _addStep,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF165932), width: 3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Добавить шаг',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color(0xFF165932),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Save recipe button
                    Padding(
                      padding: const EdgeInsets.only(left: 98, top: 21, bottom: 24),
                      child: SizedBox(
                        width: 232,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _saveRecipe,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF797676),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Сохранить рецепт',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Dialog for adding a new ingredient
class _IngredientDialog extends StatefulWidget {
  final List<String> availableIngredients;
  final List<String> availableUnits;
  final Function(Ingredient) onAdd;

  const _IngredientDialog({
    required this.availableIngredients,
    required this.availableUnits,
    required this.onAdd,
  });

  @override
  State<_IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<_IngredientDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedIngredient = '';
  final _quantityController = TextEditingController();
  String _selectedUnit = '';

  @override
  void initState() {
    super.initState();
    if (widget.availableIngredients.isNotEmpty) {
      _selectedIngredient = widget.availableIngredients[0];
    }
    if (widget.availableUnits.isNotEmpty) {
      _selectedUnit = widget.availableUnits[0];
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: 396,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog title
              const Padding(
                padding: EdgeInsets.only(top: 2, bottom: 19),
                child: Text(
                  'Ингредиент',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),

              // Ingredient name field
              Stack(
                children: [
                  Container(
                    width: 351,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECECEC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 8,
                    child: const Text(
                      'Название ингредиента',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: Color(0xFF165932),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 56,
                    child: Container(
                      width: 351,
                      height: 0,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF165932),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 24,
                    right: 16,
                    child: DropdownButtonFormField<String>(
                      value: _selectedIngredient.isNotEmpty ? _selectedIngredient : null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      items: widget.availableIngredients.map((ingredient) {
                        return DropdownMenuItem<String>(
                          value: ingredient,
                          child: Text(ingredient),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedIngredient = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, выберите ингредиент';
                        }
                        return null;
                      },
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Quantity field
              Stack(
                children: [
                  Container(
                    width: 351,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECECEC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 8,
                    child: const Text(
                      'Количество',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: Color(0xFF165932),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 56,
                    child: Container(
                      width: 351,
                      height: 0,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF165932),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 24,
                    right: 16,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Пожалуйста, введите количество';
                              }
                              return null;
                            },
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit.isNotEmpty ? _selectedUnit : null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            items: widget.availableUnits.map((unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedUnit = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Выберите единицу';
                              }
                              return null;
                            },
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // Add button
              Center(
                child: SizedBox(
                  width: 232,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onAdd(
                          Ingredient(
                            name: _selectedIngredient,
                            quantity: _quantityController.text,
                            unit: _selectedUnit,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Добавить',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dialog for adding a new step
class _StepDialog extends StatefulWidget {
  final Function(RecipeStep) onAdd;

  const _StepDialog({required this.onAdd});

  @override
  State<_StepDialog> createState() => _StepDialogState();
}

class _StepDialogState extends State<_StepDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: 396,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog title
              const Padding(
                padding: EdgeInsets.only(top: 2, bottom: 19),
                child: Text(
                  'Шаг рецепта',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),

              // Description field
              Stack(
                children: [
                  Container(
                    width: 352,
                    height: 161,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECECEC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 8,
                    child: const Text(
                      'Описание шага',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: Color(0xFF165932),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 161,
                    child: Container(
                      width: 352,
                      height: 0,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF165932),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 24,
                    right: 16,
                    bottom: 8,
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: 7,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите описание шага';
                        }
                        return null;
                      },
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              // Duration label
              const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  'Длительность шага',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),
              ),

              // Duration fields (minutes and seconds)
              Row(
                children: [
                  // Minutes field
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Container(
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Color(0xFFECECEC),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(2),
                                topRight: Radius.circular(2),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: 8,
                            child: const Text(
                              'Минуты',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                fontSize: 10,
                                color: Color(0xFF165932),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 56,
                            right: 0,
                            child: Container(
                              height: 0,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF165932),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: 24,
                            right: 8,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText: '59',
                                hintStyle: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: Color(0xFFC2C2C2),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              onChanged: (value) {
                                // Update the duration controller
                                final minutes = value.padLeft(2, '0');
                                final seconds = _durationController.text.isEmpty 
                                    ? '00' 
                                    : _durationController.text.split(':').last.padLeft(2, '0');
                                _durationController.text = '$minutes:$seconds';
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Seconds field
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Color(0xFFECECEC),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(2),
                              topRight: Radius.circular(2),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          top: 8,
                          child: const Text(
                            'Секунды',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                              color: Color(0xFF165932),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 56,
                          right: 0,
                          child: Container(
                            height: 0,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFF165932),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          top: 24,
                          right: 8,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              hintText: '59',
                              hintStyle: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                color: Color(0xFFC2C2C2),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                            onChanged: (value) {
                              // Update the duration controller
                              final minutes = _durationController.text.isEmpty 
                                  ? '00' 
                                  : _durationController.text.split(':').first.padLeft(2, '0');
                              final seconds = value.padLeft(2, '0');
                              _durationController.text = '$minutes:$seconds';
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Hidden field for the actual duration value
              Opacity(
                opacity: 0,
                child: TextFormField(
                  controller: _durationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите время';
                    }
                    // Validate time format (MM:SS)
                    final regex = RegExp(r'^\d{2}:\d{2}$');
                    if (!regex.hasMatch(value)) {
                      return 'Используйте формат ММ:СС (например, 05:00)';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 53),

              // Add button
              Center(
                child: SizedBox(
                  width: 232,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Set default values if fields are empty
                      if (_durationController.text.isEmpty) {
                        _durationController.text = '00:00';
                      }

                      if (_formKey.currentState!.validate()) {
                        widget.onAdd(
                          RecipeStep(
                            description: _descriptionController.text,
                            duration: _durationController.text,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Добавить',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
