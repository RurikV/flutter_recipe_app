import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/data/repositories/recipe_repository_impl.dart';
import 'package:flutter_recipe_app/data/models/recipe.dart';
import 'package:flutter_recipe_app/domain/services/api_service.dart';
import 'package:flutter_recipe_app/domain/services/database_service.dart';
import 'package:flutter_recipe_app/domain/services/connectivity_service.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockApiService extends Mock implements ApiService {}
class MockDatabaseService extends Mock implements DatabaseService {}
class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  group('RecipeRepository Favorites Fix Tests', () {
    late RecipeRepositoryImpl repository;
    late MockApiService mockApiService;
    late MockDatabaseService mockDatabaseService;
    late MockConnectivityService mockConnectivityService;

    setUp(() {
      mockApiService = MockApiService();
      mockDatabaseService = MockDatabaseService();
      mockConnectivityService = MockConnectivityService();
      
      repository = RecipeRepositoryImpl(
        apiService: mockApiService,
        databaseService: mockDatabaseService,
        connectivityService: mockConnectivityService,
      );
    });

    test('should preserve favorite status when cache is refreshed', () async {
      // Setup mock responses
      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      
      // Mock API responses for first load
      when(mockApiService.getRecipesData()).thenAnswer((_) async => [
        {'id': '1', 'name': 'Recipe 1', 'description': 'Test recipe 1'},
        {'id': '2', 'name': 'Recipe 2', 'description': 'Test recipe 2'},
      ]);
      when(mockApiService.getRecipeIngredientsData()).thenAnswer((_) async => []);
      when(mockApiService.getIngredientsData()).thenAnswer((_) async => []);
      when(mockApiService.getMeasureUnitsData()).thenAnswer((_) async => []);
      when(mockApiService.getRecipeStepLinksData()).thenAnswer((_) async => []);
      when(mockApiService.getRecipeStepsData()).thenAnswer((_) async => []);

      // First load - get initial recipes
      final initialRecipes = await repository.getRecipes();
      expect(initialRecipes.length, 2);
      
      // Simulate toggling favorite on first recipe
      await repository.toggleFavorite('1');
      
      // Verify recipe is now favorite
      final favorites = await repository.getFavoriteRecipes();
      expect(favorites.length, 1);
      expect(favorites.first.uuid, '1');
      
      // Second load - simulate cache refresh (this used to clear favorites)
      final refreshedRecipes = await repository.getRecipes();
      expect(refreshedRecipes.length, 2);
      
      // Verify favorites are still preserved after cache refresh
      final favoritesAfterRefresh = await repository.getFavoriteRecipes();
      expect(favoritesAfterRefresh.length, 1);
      expect(favoritesAfterRefresh.first.uuid, '1');
      
      print('[DEBUG_LOG] Test passed: Favorites preserved after cache refresh');
    });
  });
}