import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientsSection extends StatelessWidget {
  final List<Ingredient> ingredients;
  final Function() onAddIngredient;
  final Function(int) onEditIngredient;
  final Function(int) onRemoveIngredient;

  const IngredientsSection({
    super.key,
    required this.ingredients,
    required this.onAddIngredient,
    required this.onEditIngredient,
    required this.onRemoveIngredient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ingredients header
        Padding(
          padding: const EdgeInsets.only(top: 19),
          child: Text(
            'Ингредиенты',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 23/16,
              color: const Color(0xFF165932),
            ),
          ),
        ),

        // Ingredients list or placeholder
        if (ingredients.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Center(
              child: Text(
                'нет ингредиентов',
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
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(
                      ingredient.name,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '${ingredient.quantity} ${ingredient.unit}',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF797676),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => onEditIngredient(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => onRemoveIngredient(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // Add ingredient button
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: SizedBox(
            width: 232,
            height: 48,
            child: OutlinedButton(
              onPressed: onAddIngredient,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF165932), width: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Добавить ингредиент',
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
