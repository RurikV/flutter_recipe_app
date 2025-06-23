import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/recipe_step.dart';

class StepDialog extends StatefulWidget {
  final Function(RecipeStep) onSave;
  final RecipeStep? step; // Optional - if provided, we're in edit mode

  const StepDialog({
    super.key,
    required this.onSave,
    this.step,
  });

  @override
  State<StepDialog> createState() => _StepDialogState();
}

class _StepDialogState extends State<StepDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  late String _minutes;
  late String _seconds;
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.step != null;

    if (_isEditMode) {
      // Initialize with the existing step values
      _descriptionController = TextEditingController(text: widget.step!.description);
      _durationController = TextEditingController(text: widget.step!.duration);

      // Parse the duration into minutes and seconds
      final parts = widget.step!.duration.split(':');
      if (parts.length == 2) {
        _minutes = parts[0];
        _seconds = parts[1];
      } else {
        _minutes = '00';
        _seconds = '00';
      }
    } else {
      // Initialize with default values
      _descriptionController = TextEditingController();
      _durationController = TextEditingController();
      _minutes = '00';
      _seconds = '00';
    }
  }

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
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 19),
                child: Text(
                  _isEditMode ? 'Редактировать шаг рецепта' : 'Шаг рецепта',
                  style: const TextStyle(
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
                  if (_isEditMode)
                    Positioned(
                      left: 33,
                      top: 87,
                      width: 318,
                      height: 80,
                      child: Text(
                        _descriptionController.text,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 18 / 16,
                          color: Colors.black,
                        ),
                      ),
                    )
                  else
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
                          if (_isEditMode)
                            Positioned(
                              left: 25.37,
                              top: 283 - 255,
                              child: Text(
                                _minutes,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  height: 23 / 20,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          else
                            Positioned(
                              left: 8,
                              top: 14,
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
                        if (_isEditMode)
                          Positioned(
                            left: 205.56,
                            top: 283 - 255,
                            child: Text(
                              _seconds,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                height: 23 / 20,
                                color: Colors.black,
                              ),
                            ),
                          )
                        else
                          Positioned(
                            left: 8,
                            top: 14,
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

              // Action button (Add or Save)
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
                        widget.onSave(
                          RecipeStep(
                            description: _descriptionController.text,
                            duration: _durationController.text,
                            isCompleted: _isEditMode ? widget.step!.isCompleted : false,
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