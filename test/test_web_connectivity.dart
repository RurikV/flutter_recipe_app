import 'package:flutter/foundation.dart';
import 'package:recipe_master/services/api/api_service_impl.dart';
import 'package:recipe_master/config/app_config.dart';

void main() async {
  print('🔍 Testing Flutter Web API Connectivity...\n');

  // Force web platform for testing
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia; // This simulates web

  try {
    print('1. Testing API configuration...');
    print('Base URL: ${AppConfig.baseUrl}');
    print('Is Web: $kIsWeb');

    print('\n2. Creating API service...');
    final apiService = ApiServiceImpl();

    print('\n3. Testing recipe data retrieval...');
    final recipeData = await apiService.getRecipeData('3');

    print('✅ Recipe data retrieved successfully!');
    print('Recipe keys: ${recipeData.keys.toList()}');
    print('Recipe name: ${recipeData['name']}');
    print('Has recipeIngredients: ${recipeData.containsKey('recipeIngredients')}');
    print('Has recipeStepLinks: ${recipeData.containsKey('recipeStepLinks')}');

    if (recipeData.containsKey('recipeIngredients')) {
      final ingredients = recipeData['recipeIngredients'] as List?;
      print('Ingredients count: ${ingredients?.length ?? 0}');
    }

    if (recipeData.containsKey('recipeStepLinks')) {
      final steps = recipeData['recipeStepLinks'] as List?;
      print('Steps count: ${steps?.length ?? 0}');
    }

    print('\n🎉 Web connectivity test completed successfully!');

  } catch (e) {
    print('❌ Web connectivity test failed: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}
