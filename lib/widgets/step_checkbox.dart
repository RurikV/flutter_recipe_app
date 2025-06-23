import 'package:flutter/material.dart';

/// A stateless widget representing the step checkbox.
class StepCheckbox extends StatelessWidget {
  final bool isCompleted;
  final bool isCookingMode;
  final Function(bool) onChanged;

  const StepCheckbox({
    super.key,
    required this.isCompleted,
    required this.isCookingMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: isCompleted,
      onChanged: isCookingMode ? (value) {
        final newValue = value ?? false;
        onChanged(newValue);
      } : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      side: BorderSide(
        color: isCookingMode ? const Color(0xFF165932) : const Color(0xFF797676),
        width: 4,
      ),
    );
  }
}