import 'package:flutter/material.dart';
import '../../data/entities/recipe_step.dart';
import 'recipe_steps_header.dart';
import 'recipe_step_item.dart';

class RecipeStepsList extends StatelessWidget {
  final List<RecipeStep> steps;
  final bool isCookingMode;
  final String recipeId;
  final Function(int, bool) onStepStatusChanged;

  const RecipeStepsList({
    super.key,
    required this.steps,
    required this.isCookingMode,
    required this.recipeId,
    required this.onStepStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Steps header
        const RecipeStepsHeader(),

        // Steps list
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              return RecipeStepItem(
                step: step,
                index: index,
                isCookingMode: isCookingMode,
                onStepStatusChanged: onStepStatusChanged,
              );
            }),
          ),
        ),
      ],
    );
  }
}
