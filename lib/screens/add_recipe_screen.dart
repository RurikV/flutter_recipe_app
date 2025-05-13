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
      appBar: AppBar(
        title: const Text('Новый рецепт'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image placeholder
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Recipe name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название рецепта',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите название рецепта';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Recipe description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Описание',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите описание рецепта';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Recipe duration
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Время приготовления (например, "30 минут")',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите время приготовления';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Image URL (optional)
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL изображения (необязательно)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Ingredients section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ингредиенты',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addIngredient,
                          icon: const Icon(Icons.add),
                          label: const Text('Добавить'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Ingredients list
                    if (_ingredients.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text('Нет добавленных ингредиентов'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _ingredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = _ingredients[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              title: Text(ingredient.name),
                              subtitle: Text('${ingredient.quantity} ${ingredient.unit}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeIngredient(index),
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                    
                    // Steps section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Шаги приготовления',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addStep,
                          icon: const Icon(Icons.add),
                          label: const Text('Добавить'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Steps list
                    if (_steps.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text('Нет добавленных шагов'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _steps.length,
                        itemBuilder: (context, index) {
                          final step = _steps[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(step.description),
                              subtitle: Text('Время: ${step.duration}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeStep(index),
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 32),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveRecipe,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: const Text('Сохранить рецепт'),
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
    return AlertDialog(
      title: const Text('Добавить ингредиент'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ingredient dropdown
            DropdownButtonFormField<String>(
              value: _selectedIngredient.isNotEmpty ? _selectedIngredient : null,
              decoration: const InputDecoration(
                labelText: 'Ингредиент',
                border: OutlineInputBorder(),
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
            ),
            const SizedBox(height: 16),
            
            // Quantity field
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Количество',
                border: OutlineInputBorder(),
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
            ),
            const SizedBox(height: 16),
            
            // Unit dropdown
            DropdownButtonFormField<String>(
              value: _selectedUnit.isNotEmpty ? _selectedUnit : null,
              decoration: const InputDecoration(
                labelText: 'Единица измерения',
                border: OutlineInputBorder(),
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
                  return 'Пожалуйста, выберите единицу измерения';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
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
          child: const Text('Добавить'),
        ),
      ],
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
    return AlertDialog(
      title: const Text('Добавить шаг'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите описание шага';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Duration field
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Время (например, "05:00")',
                border: OutlineInputBorder(),
              ),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
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
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}