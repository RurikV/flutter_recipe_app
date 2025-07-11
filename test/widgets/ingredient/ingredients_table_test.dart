import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_master/data/models/ingredient.dart';
import 'package:recipe_master/widgets/ingredient/ingredients_table.dart';

void main() {
  group('IngredientsTable Widget Tests', () {
    testWidgets('displays empty message when no ingredients', (WidgetTester tester) async {
      // Build the widget with an empty list
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IngredientsTable(ingredients: []),
          ),
        ),
      );

      // Verify that the empty message is displayed
      expect(find.text('Нет ингредиентов'), findsOneWidget);
      expect(find.byType(Table), findsNothing);
    });

    testWidgets('displays ingredients in a table', (WidgetTester tester) async {
      // Create test ingredients
      final ingredients = [
        Ingredient.simple(name: 'Flour', quantity: '200', unit: 'g'),
        Ingredient.simple(name: 'Sugar', quantity: '100', unit: 'g'),
        Ingredient.simple(name: 'Eggs', quantity: '2', unit: ''),
      ];

      // Build the widget with the test ingredients
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IngredientsTable(ingredients: ingredients),
          ),
        ),
      );

      // Verify that the table is displayed
      expect(find.byType(Table), findsOneWidget);

      // Verify that each ingredient is displayed
      for (final ingredient in ingredients) {
        expect(find.text(ingredient.name), findsOneWidget);
        expect(find.text('${ingredient.quantity} ${ingredient.unit}'), findsOneWidget);
      }
    });
  });
}
