import 'package:flutter/material.dart';
import '../../data/models/recipe_step.dart';
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
    print('[DEBUG_LOG] RecipeStepsList: Building widget with ${steps.length} steps');
    if (steps.isNotEmpty) {
      print('[DEBUG_LOG] RecipeStepsList: Steps received:');
      for (int i = 0; i < steps.length; i++) {
        final step = steps[i];
        print('[DEBUG_LOG]   ${i + 1}. ${step.name} (${step.duration} min)');
      }
    } else {
      print('[DEBUG_LOG] RecipeStepsList: ⚠️ NO STEPS received!');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Steps header
        const RecipeStepsHeader(),

        // Steps list
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: _buildStepsContent(),
        ),
      ],
    );
  }

  /// Builds the steps content based on whether there are steps
  Widget _buildStepsContent() {
    if (steps.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF797676), width: 3),
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Нет шагов приготовления',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        return RecipeStepItem(
          step: step,
          index: index,
          isCookingMode: isCookingMode,
          onStepStatusChanged: onStepStatusChanged,
        );
      }),
    );
  }
}
