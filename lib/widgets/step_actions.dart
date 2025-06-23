import 'package:flutter/material.dart';
import 'step_checkbox.dart';
import 'step_duration.dart';

/// A stateless widget representing the step actions (checkbox and duration).
class StepActions extends StatelessWidget {
  final String duration;
  final bool isCompleted;
  final bool isCookingMode;
  final Function(bool) onChanged;

  const StepActions({
    super.key,
    required this.duration,
    required this.isCompleted,
    required this.isCookingMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        StepCheckbox(
          isCompleted: isCompleted,
          isCookingMode: isCookingMode,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        StepDuration(
          duration: duration,
          isCompleted: isCompleted,
          isCookingMode: isCookingMode,
        ),
      ],
    );
  }
}