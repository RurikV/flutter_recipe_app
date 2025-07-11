import 'package:flutter/material.dart';
import '../../data/models/recipe_step.dart';

class StepsSection extends StatelessWidget {
  final List<RecipeStep> steps;
  final Function() onAddStep;
  final Function(int) onEditStep;
  final Function(int) onRemoveStep;

  const StepsSection({
    super.key,
    required this.steps,
    required this.onAddStep,
    required this.onEditStep,
    required this.onRemoveStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Steps header
        Padding(
          padding: const EdgeInsets.only(top: 42),
          child: Text(
            'Шаги приготовления',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 23/16,
              color: const Color(0xFF165932),
            ),
          ),
        ),

        // Steps list or placeholder
        if (steps.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Center(
              child: Text(
                'нет шагов приготовления',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  height: 23/12,
                  color: Colors.black,
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: Color(0xFFC2C2C2),
                      ),
                    ),
                    title: Text(
                      step.name,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF797676),
                      ),
                    ),
                    subtitle: Text(
                      'Время: ${step.duration} мин',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF797676),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => onEditStep(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => onRemoveStep(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // Add step button
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: SizedBox(
            width: 232,
            height: 48,
            child: OutlinedButton(
              onPressed: onAddStep,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF165932), width: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Добавить шаг',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF165932),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
