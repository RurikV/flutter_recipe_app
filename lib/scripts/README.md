# API Data Seeding Scripts

This directory contains scripts to populate the API database with sample data from the Flutter app.

## Prerequisites

1. Make sure the API server is running on `http://localhost:3000`
2. The API database should be initialized (tables created)

## Usage

### Seed All Data

To populate the API database with all dummy data from the Flutter app:

```bash
# From the project root directory
dart run lib/scripts/seed_api_data.dart
```

This script will:

1. **Create a test user** with credentials:
   - Login: `testuser`
   - Password: `testpassword123`

2. **Seed measure units** (11 units):
   - ст. ложка, ч. ложка, стакан, мл, л, г, кг, шт, зубчик, по вкусу, щепотка

3. **Seed ingredients** (38 ingredients):
   - All ingredients from the Flutter app's dummy data with calculated calories

4. **Seed recipes** (5 complete recipes):
   - Спагетти Карбонара (with full ingredients and 6 steps)
   - Борщ
   - Греческий салат
   - Суши Филадельфия
   - Тирамису

## Data Structure

The seeded data matches the API schema:

- **Users**: Test user for authentication
- **MeasureUnits**: Units of measurement for ingredients
- **Ingredients**: Food items with nutritional information
- **Recipes**: Recipe information with photos and duration
- **RecipeSteps**: Individual cooking steps
- **RecipeStepLinks**: Links between recipes and steps
- **RecipeIngredients**: Links between recipes and ingredients

## Error Handling

The script includes comprehensive error handling:
- Skips existing data (409 conflicts)
- Logs success and failure messages
- Continues processing even if individual items fail

## Verification

After running the script, you can verify the data by:

1. Checking the API endpoints:
   - `GET http://localhost:3000/recipe` - Should return 5 recipes
   - `GET http://localhost:3000/ingredient` - Should return 38 ingredients
   - `GET http://localhost:3000/measure_unit` - Should return 11+ units

2. Using the API documentation at `http://localhost:3000/api-docs`

## Notes

- The script is idempotent - you can run it multiple times safely
- Existing data will not be duplicated
- The script uses the same dummy data that the Flutter app uses for offline mode
- All text is in Russian to match the original Flutter app data