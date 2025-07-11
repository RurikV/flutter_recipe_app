import 'package:flutter/material.dart';
import '../../data/entities/recipe_step.dart';
import 'step_number.dart';
import 'step_description.dart';
import 'step_actions.dart';

/// A stateless widget representing a single recipe step item.
class RecipeStepItem extends StatelessWidget {
  final RecipeStep step;
  final int index;
  final bool isCookingMode;
  final Function(int, bool) onStepStatusChanged;

  const RecipeStepItem({
    super.key,
    required this.step,
    required this.index,
    required this.isCookingMode,
    required this.onStepStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: isCookingMode && step.isCompleted 
              ? const Color(0xFFE8F5E9) // Light green when completed in cooking mode
              : const Color(0xFFECECEC), // Default gray
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step number
              StepNumber(
                index: index,
                isCompleted: step.isCompleted,
                isCookingMode: isCookingMode,
              ),

              // Step description
              StepDescription(
                description: step.description,
                isCompleted: step.isCompleted,
                isCookingMode: isCookingMode,
              ),

              // Step duration and checkbox
              StepActions(
                duration: step.duration,
                isCompleted: step.isCompleted,
                isCookingMode: isCookingMode,
                onChanged: (value) {
                  onStepStatusChanged(index, value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
