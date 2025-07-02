import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A stateless widget representing the step checkbox.
class StepCheckbox extends StatelessWidget {
  final bool isCompleted;
  final bool isCookingMode;
  final ValueChanged<bool> onChanged;

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
        color: isCookingMode ? AppColors.checkboxActiveCooking : AppColors.checkboxInactive,
        width: 4,
      ),
    );
  }
}
