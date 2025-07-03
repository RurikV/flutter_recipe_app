import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/ingredient.dart';

class IngredientDialog extends StatefulWidget {
  final List<String> availableIngredients;
  final List<String> availableUnits;
  final Function(Ingredient) onSave;
  final Ingredient? ingredient; // Optional - if provided, we're in edit mode

  const IngredientDialog({
    super.key,
    required this.availableIngredients,
    required this.availableUnits,
    required this.onSave,
    this.ingredient,
  });

  @override
  State<IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<IngredientDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedIngredient;
  late TextEditingController _quantityController;
  late String _selectedUnit;
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.ingredient != null;

    // Ensure we have non-empty lists for dropdowns
    final safeIngredients = widget.availableIngredients.isNotEmpty 
        ? widget.availableIngredients 
        : ['Ингредиент']; // Default if empty

    final safeUnits = widget.availableUnits.isNotEmpty 
        ? widget.availableUnits 
        : ['шт']; // Default if empty

    if (_isEditMode) {
      // Initialize with the existing ingredient values
      _selectedIngredient = widget.ingredient!.name;
      _quantityController = TextEditingController(text: widget.ingredient!.quantity);
      _selectedUnit = widget.ingredient!.unit;
    } else {
      // Initialize with default values
      _selectedIngredient = safeIngredients.first;
      _quantityController = TextEditingController();
      _selectedUnit = safeUnits.first;
    }

    // Debug output to verify initialization
    debugPrint('Initialized with _selectedIngredient=$_selectedIngredient, _selectedUnit=$_selectedUnit');
    debugPrint('Available ingredients: ${safeIngredients.join(', ')}');
    debugPrint('Available units: ${safeUnits.join(', ')}');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building IngredientDialog with _selectedIngredient=$_selectedIngredient, _selectedUnit=$_selectedUnit');

    // Ensure we have non-empty lists for dropdowns
    final safeIngredients = widget.availableIngredients.isNotEmpty 
        ? widget.availableIngredients 
        : ['Ингредиент']; // Default if empty

    final safeUnits = widget.availableUnits.isNotEmpty 
        ? widget.availableUnits 
        : ['шт']; // Default if empty

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
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 19),
                child: Text(
                  _isEditMode ? 'Редактировать ингредиент' : 'Ингредиент',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),

              // Ingredient name field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 351,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECECEC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(2),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF165932),
                          width: 2,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 8, left: 18, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Название ингредиента',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: Color(0xFF165932),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_isEditMode)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              _selectedIngredient,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 23 / 16,
                                color: Colors.black,
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedIngredient.isNotEmpty ? _selectedIngredient : safeIngredients.first,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                underline: Container(height: 0),
                                items: safeIngredients.toSet().toList().map((ingredient) {
                                  return DropdownMenuItem<String>(
                                    value: ingredient,
                                    child: Text(ingredient),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedIngredient = value;
                                    });
                                  }
                                },
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                dropdownColor: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Quantity field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 351,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECECEC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(2),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF165932),
                          width: 2,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 8, left: 18, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Количество и единица измерения',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: Color(0xFF165932),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_isEditMode)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              '${_quantityController.text} $_selectedUnit',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 23 / 16,
                                color: Colors.black,
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _quantityController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      hintText: 'Введите количество',
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
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: const Color(0xFF165932),
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: DropdownButton<String>(
                                      value: _selectedUnit.isNotEmpty ? _selectedUnit : safeUnits.first,
                                      isExpanded: true,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      underline: Container(height: 0),
                                      items: safeUnits.toSet().toList().map((unit) {
                                        return DropdownMenuItem<String>(
                                          value: unit,
                                          child: Text(unit),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedUnit = value;
                                          });
                                        }
                                      },
                                      style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      dropdownColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // Action button (Add or Save)
              Center(
                child: SizedBox(
                  width: 232,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint('Add button pressed');

                      // Validate the form
                      if (_formKey.currentState!.validate()) {
                        // Create a new ingredient only if validation passes
                        final ingredient = Ingredient(
                          name: _selectedIngredient,
                          quantity: _quantityController.text.isNotEmpty ? _quantityController.text : '1',
                          unit: _selectedUnit,
                        );

                        debugPrint('Created ingredient: ${ingredient.name}, ${ingredient.quantity}, ${ingredient.unit}');

                        // Call the onSave callback
                        widget.onSave(ingredient);
                        debugPrint('onSave callback called');

                        // Dismiss the dialog
                        Navigator.pop(context);
                        debugPrint('Dialog closed');
                      } else {
                        debugPrint('Form validation failed');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      _isEditMode ? 'Сохранить' : 'Добавить',
                      style: const TextStyle(
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
