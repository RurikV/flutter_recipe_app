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

    if (_isEditMode) {
      // Initialize with the existing ingredient values
      _selectedIngredient = widget.ingredient!.name;
      _quantityController = TextEditingController(text: widget.ingredient!.quantity);
      _selectedUnit = widget.ingredient!.unit;
    } else {
      // Initialize with default values
      _selectedIngredient = widget.availableIngredients.isNotEmpty ? widget.availableIngredients[0] : '';
      _quantityController = TextEditingController();
      _selectedUnit = widget.availableUnits.isNotEmpty ? widget.availableUnits[0] : '';
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
                  if (_isEditMode)
                    Positioned(
                      left: 34,
                      top: 79 - 56,
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
                    Positioned(
                      left: 18,
                      top: 14,
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
                  if (_isEditMode)
                    Positioned(
                      left: 33,
                      top: 149 - 127,
                      child: Text(
                        '${_quantityController.text} ${_selectedUnit}',
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
                    Positioned(
                      left: 18,
                      top: 14,
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
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedUnit.isNotEmpty ? _selectedUnit : null,
                              isExpanded: true,
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

              // Action button (Add or Save)
              Center(
                child: SizedBox(
                  width: 232,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave(
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
