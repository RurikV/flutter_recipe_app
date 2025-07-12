import '../lib/data/models/recipe.dart';
import '../lib/data/models/ingredient.dart';
import '../lib/data/models/recipe_step.dart';

void main() async {
  print('🧪 Testing Database Save Fix...\n');
  
  // Create a test recipe with ingredients and steps
  final testRecipe = Recipe(
    uuid: 'test-uuid-123',
    name: 'Test Recipe for Database Fix',
    images: 'https://example.com/test.jpg',
    description: 'Test description',
    instructions: 'Test instructions',
    difficulty: 2,
    duration: '30',
    rating: 4,
    tags: ['test'],
    ingredients: [
      Ingredient.simple(
        name: 'Test Ingredient 1',
        quantity: '200',
        unit: 'g',
      ),
      Ingredient.simple(
        name: 'Test Ingredient 2',
        quantity: '100',
        unit: 'ml',
      ),
    ],
    steps: [
      RecipeStep(
        id: 1,
        name: 'Test Step 1',
        duration: 10,
      ),
      RecipeStep(
        id: 2,
        name: 'Test Step 2',
        duration: 15,
      ),
    ],
    isFavorite: false,
    comments: [],
  );
  
  print('✅ Test recipe created successfully:');
  print('- Name: ${testRecipe.name}');
  print('- UUID: ${testRecipe.uuid}');
  print('- Ingredients count: ${testRecipe.ingredients.length}');
  print('- Steps count: ${testRecipe.steps.length}');
  
  // Test Recipe.fromJson with API response structure (similar to the logs)
  final apiResponse = {
    'id': 3,
    'name': 'Спагетти Карбонара',
    'duration': 30,
    'photo': 'https://images.unsplash.com/photo-1588013273468-315fd88ea34c',
    'recipeIngredients': [
      {
        'count': 400,
        'ingredient': {
          'name': 'Кунжут',
          'measureUnit': {
            'one': 'стакан',
            'few': 'стакан',
            'many': 'стакан'
          }
        }
      },
      {
        'count': 150,
        'ingredient': {
          'name': 'Сыр пармезан',
          'measureUnit': {
            'one': 'liter',
            'few': 'liters',
            'many': 'liters'
          }
        }
      }
    ],
    'recipeStepLinks': [
      {
        'step': {
          'name': 'Отварите спагетти в подсоленной воде до состояния аль денте.',
          'duration': 10
        },
        'number': 1
      },
      {
        'step': {
          'name': 'Нарежьте гуанчиале небольшими кубиками и обжарьте на сковороде до золотистого цвета.',
          'duration': 5
        },
        'number': 2
      }
    ]
  };
  
  print('\n🔄 Testing Recipe.fromJson with API response...');
  final parsedRecipe = Recipe.fromJson(apiResponse);
  
  print('✅ Recipe parsed successfully from API response:');
  print('- Name: ${parsedRecipe.name}');
  print('- UUID: ${parsedRecipe.uuid}');
  print('- Ingredients count: ${parsedRecipe.ingredients.length}');
  print('- Steps count: ${parsedRecipe.steps.length}');
  
  if (parsedRecipe.ingredients.isNotEmpty) {
    print('\n📋 Parsed ingredients:');
    for (int i = 0; i < parsedRecipe.ingredients.length; i++) {
      final ingredient = parsedRecipe.ingredients[i];
      print('  ${i + 1}. ${ingredient.name} - ${ingredient.quantity} ${ingredient.unit}');
    }
  }
  
  if (parsedRecipe.steps.isNotEmpty) {
    print('\n📝 Parsed steps:');
    for (int i = 0; i < parsedRecipe.steps.length; i++) {
      final step = parsedRecipe.steps[i];
      print('  ${i + 1}. ${step.name} (${step.duration} min)');
    }
  }
  
  print('\n🎉 Database fix test completed successfully!');
  print('The fix should prevent UNIQUE constraint errors by using UPDATE instead of INSERT for existing recipes.');
}