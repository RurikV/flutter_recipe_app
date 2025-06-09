import 'package:flutter/material.dart';
import '../models/recipe_step.dart';

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
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Text(
            'Шаги приготовления',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 23 / 16, // line-height from design
              color: Color(0xFF165932),
            ),
          ),
        ),

        // Steps list
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: List.generate(steps.length, (index) {
              final step = steps[index];
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
                        SizedBox(
                          width: 30,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w900,
                              fontSize: 40,
                              height: 27 / 40, // line-height from design
                              color: isCookingMode && step.isCompleted 
                                  ? const Color(0xFF2ECC71) // Green when completed in cooking mode
                                  : const Color(0xFFC2C2C2), // Default gray
                            ),
                          ),
                        ),

                        // Step description
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              step.description,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 18 / 12, // line-height from design
                                color: isCookingMode && step.isCompleted 
                                    ? const Color(0xFF2D490C) // Dark green when completed in cooking mode
                                    : const Color(0xFF797676), // Default gray
                              ),
                            ),
                          ),
                        ),

                        // Step duration and checkbox
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Checkbox(
                              value: step.isCompleted,
                              onChanged: isCookingMode ? (value) {
                                final newValue = value ?? false;
                                onStepStatusChanged(index, newValue);
                              } : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              side: BorderSide(
                                color: isCookingMode ? const Color(0xFF165932) : const Color(0xFF797676),
                                width: 4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              step.duration,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                height: 20 / 13, // line-height from design
                                color: isCookingMode && step.isCompleted 
                                    ? const Color(0xFF165932) // Green when completed in cooking mode
                                    : const Color(0xFF797676), // Default gray
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}