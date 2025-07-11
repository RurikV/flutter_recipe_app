import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_master/data/entities/ingredient.dart';
import 'package:recipe_master/widgets/ingredient/ingredient_dialog.dart';

void main() {
  group('IngredientDialog Widget Tests', () {
    testWidgets('displays ingredient dialog with measure unit choice', (WidgetTester tester) async {
      // Define available ingredients and units
      final availableIngredients = ['Flour', 'Sugar', 'Eggs'];
      final availableUnits = ['g', 'kg', 'ml', 'l', 'pcs'];

      // Create a variable to store the saved ingredient
      Ingredient? savedIngredient;

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => IngredientDialog(
                      availableIngredients: availableIngredients,
                      availableUnits: availableUnits,
                      onSave: (ingredient) {
                        savedIngredient = ingredient;
                      },
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed
      expect(find.text('Ингредиент'), findsOneWidget);

      // Verify that the ingredient dropdown is displayed
      expect(find.byType(DropdownButton<String>), findsAtLeastNWidgets(2));

      // Select an ingredient
      await tester.tap(find.byType(DropdownButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sugar').last);
      await tester.pumpAndSettle();

      // Enter a quantity
      await tester.enterText(find.byType(TextFormField), '100');

      // Select a unit
      await tester.tap(find.byType(DropdownButton<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('kg').last);
      await tester.pumpAndSettle();

      // Tap the add button
      await tester.tap(find.text('Добавить'));
      await tester.pumpAndSettle();

      // Verify that the dialog is closed
      expect(find.text('Ингредиент'), findsNothing);

      // Verify that the ingredient was saved with the correct values
      expect(savedIngredient, isNotNull);
      expect(savedIngredient!.name, equals('Sugar'));
      expect(savedIngredient!.quantity, equals('100'));
      expect(savedIngredient!.unit, equals('kg'));
    });

    testWidgets('validates form before saving ingredient', (WidgetTester tester) async {
      // Define available ingredients and units
      final availableIngredients = ['Flour', 'Sugar', 'Eggs'];
      final availableUnits = ['g', 'kg', 'ml', 'l', 'pcs'];

      // Create a variable to store the saved ingredient
      Ingredient? savedIngredient;

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => IngredientDialog(
                      availableIngredients: availableIngredients,
                      availableUnits: availableUnits,
                      onSave: (ingredient) {
                        savedIngredient = ingredient;
                      },
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Clear the quantity field
      await tester.enterText(find.byType(TextFormField), '');

      // Tap the add button
      await tester.tap(find.text('Добавить'));
      await tester.pumpAndSettle();

      // Verify that the dialog is still open (form validation failed)
      expect(find.text('Ингредиент'), findsOneWidget);

      // Verify that the error message is displayed
      expect(find.text('Пожалуйста, введите количество'), findsOneWidget);

      // Enter a valid quantity
      await tester.enterText(find.byType(TextFormField), '100');

      // Tap the add button again
      await tester.tap(find.text('Добавить'));
      await tester.pumpAndSettle();

      // Verify that the dialog is closed
      expect(find.text('Ингредиент'), findsNothing);

      // Verify that the ingredient was saved with the correct values
      expect(savedIngredient, isNotNull);
      expect(savedIngredient!.quantity, equals('100'));
    });
  });
}
