# Flutter Recipe App - FoodApiTest Integration

This document summarizes the changes made to integrate the Flutter Recipe App with the FoodApiTest API. The changes were made based on the FoodApiTest example, which demonstrates how to show a recipe with ingredients, measure units, and steps, and how to add them to a recipe.

## Changes Made

### 1. New Models

The following new models were created to match the FoodApiTest API:

- **MeasureUnit**: Represents a unit of measurement with different grammatical forms (one, few, many).
- **MeasureUnitRef**: A reference to a MeasureUnit by ID.
- **RecipeIngredient**: Connects recipes and ingredients with a count.
- **IngredientRef**: A reference to an Ingredient by ID.
- **RecipeRef**: A reference to a Recipe by ID.
- **RecipeStepLink**: Connects recipes and steps with a sequence number.
- **StepRef**: A reference to a RecipeStep by ID.

### 2. Updated Models

The following existing models were updated to match the FoodApiTest API:

- **Ingredient**: Added ID, caloriesForUnit, and measureUnit fields, and kept the original fields for backward compatibility.
- **RecipeStep**: Changed description to name, duration to int, and kept the original fields for backward compatibility.

### 3. Entity Converters

The EntityConverters class was updated to handle the new model structures:

- When converting from entity to model, use the simple constructors for Ingredient and RecipeStep.
- When converting from model to entity, handle the field name differences.

### 4. Tests

The following tests were created to demonstrate the usage of the new models:

- **Unit Test**: Shows how to create a recipe with ingredients, measure units, and steps using the FoodApiTest approach.
- **Integration Test**: Shows how to display a recipe with ingredients and steps in the UI.

## Recommendations

### 1. Generate JSON Serialization Code

The new models use the @JsonSerializable annotation for JSON serialization/deserialization. You need to run the build_runner to generate the necessary code:

```bash
flutter pub run build_runner build
```

### 2. Update UI Components

The UI components should be updated to use the new models. The integration test provides an example of how to display a recipe with ingredients and steps.

### 3. Update API Service

The API service should be updated to use the new models when communicating with the FoodApiTest API.

### 4. Update Database Service

The database service should be updated to store and retrieve the new models.

### 5. Update Recipe Manager

The recipe manager should be updated to handle the new models and relationships.

## Example Usage

### Creating a Recipe with Ingredients and Steps

```dart
// Create measure units
final gramsUnit = MeasureUnitRef(id: 1);
final piecesUnit = MeasureUnitRef(id: 2);

// Create ingredients
final pasta = Ingredient(
  id: 1,
  name: 'Pasta',
  caloriesForUnit: 350.0,
  measureUnit: gramsUnit,
);

final eggs = Ingredient(
  id: 2,
  name: 'Eggs',
  caloriesForUnit: 70.0,
  measureUnit: piecesUnit,
);

// Create recipe steps
final step1 = RecipeStep.simple(
  description: 'Boil water in a large pot',
  duration: '5',
);

final step2 = RecipeStep.simple(
  description: 'Cook pasta according to package instructions',
  duration: '10',
);

// Create recipe
final recipe = Recipe(
  uuid: '999',
  name: 'Spaghetti Carbonara',
  images: 'https://example.com/carbonara.jpg',
  description: 'A delicious pasta dish',
  instructions: 'Cook pasta, mix with eggs and bacon',
  difficulty: 2,
  duration: '30',
  rating: 5,
  tags: ['pasta', 'italian'],
  ingredients: [
    Ingredient.simple(name: 'Pasta', quantity: '200', unit: 'g'),
    Ingredient.simple(name: 'Eggs', quantity: '3', unit: 'pcs'),
  ],
  steps: [
    step1,
    step2,
  ],
);
```

### Creating Recipe Ingredients and Step Links

```dart
// Create recipe ingredients
final recipeIngredient1 = RecipeIngredient(
  id: 1,
  count: 200,
  ingredient: IngredientRef(id: pasta.id),
  recipe: RecipeRef(id: int.parse(recipe.uuid)),
);

// Create recipe step links
final stepLink1 = RecipeStepLink(
  id: 1,
  number: 1,
  recipe: RecipeRef(id: int.parse(recipe.uuid)),
  step: StepRef(id: 1),
);
```

## Conclusion

The changes made to the Flutter Recipe App allow it to integrate with the FoodApiTest API. The new models and relationships provide a more structured way to represent recipes, ingredients, and steps, while maintaining backward compatibility with the existing code.

The unit and integration tests demonstrate how to use the new models and can serve as a reference for further development.