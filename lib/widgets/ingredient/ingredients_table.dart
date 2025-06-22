// ignore_for_file: unnecessary_null_comparison, prefer_null_aware_operators, invalid_use_of_protected_member, null_check_on_nullable_type_parameter
import 'package:flutter/material.dart';

/// A widget that displays a table of ingredients
class IngredientsTable extends StatelessWidget {
  final List ingredients;

  const IngredientsTable({
    super.key,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ingredients header
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Text(
            'Ингредиенты',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 23 / 16, // line-height from design
              color: Color(0xFF165932),
            ),
          ),
        ),

        // Ingredients table
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF797676), width: 3),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildTableContent(),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the table content based on whether there are ingredients
  Widget _buildTableContent() {
    if (ingredients.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Нет ингредиентов',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      );
    }

    // Convert ingredients to a list of maps with string values
    final List<Map<String, String>> safeIngredients = [];

    for (final ingredient in ingredients) {
      if (ingredient != null) {
        final Map<String, String> data = {};

        try {
          data['name'] = ingredient.name?.toString() ?? '';
        } catch (_) {
          data['name'] = '';
        }

        try {
          data['quantity'] = ingredient.quantity?.toString() ?? '';
        } catch (_) {
          data['quantity'] = '';
        }

        try {
          data['unit'] = ingredient.unit?.toString() ?? '';
        } catch (_) {
          data['unit'] = '';
        }

        safeIngredients.add(data);
      }
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
      },
      children: safeIngredients.map<TableRow>((data) {
        return TableRow(
          children: [
            // Ingredient name
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                data['name'] ?? '',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 27 / 14, // line-height from design
                  color: Colors.black,
                ),
              ),
            ),
            // Quantity and unit
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '${data['quantity'] ?? ''} ${data['unit'] ?? ''}',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  height: 27 / 13, // line-height from design
                  color: Color(0xFF797676),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
