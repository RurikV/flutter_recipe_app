import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/recipe_step.dart';
import '../models/comment.dart';
import '../data/api_service.dart';
import '../data/database_service.dart';
import 'connectivity_service.dart';

class RecipeManager {
  final ApiService _apiService;
  final DatabaseService _databaseService;
  final ConnectivityService _connectivityService;

  // Regular class constructor
  RecipeManager({
    ApiService? apiService,
    DatabaseService? databaseService,
    ConnectivityService? connectivityService,
  })  : _apiService = apiService ?? ApiService(),
        _databaseService = databaseService ?? DatabaseService(),
        _connectivityService = connectivityService ?? ConnectivityService();

  // Hardcoded list of ingredients (fallback)
  final List<String> _dummyIngredients = [
    'Соевый соус',
    'Вода',
    'Мёд',
    'Коричневый сахар',
    'Чеснок',
    'Тёртый свежий имбирь',
    'Лимонный сок',
    'Кукурузный крахмал',
    'Растительное масло',
    'Филе лосося или сёмги',
    'Кунжут',
    'Спагетти',
    'Яйца',
    'Сыр пармезан',
    'Гуанчиале',
    'Черный перец',
    'Свекла',
    'Капуста',
    'Картофель',
    'Морковь',
    'Лук',
    'Томатная паста',
    'Помидоры',
    'Огурцы',
    'Болгарский перец',
    'Красный лук',
    'Оливки',
    'Сыр фета',
    'Оливковое масло',
    'Лосось',
    'Сливочный сыр',
    'Авокадо',
    'Рис для суши',
    'Нори',
    'Маскарпоне',
    'Кофе',
    'Печенье савоярди',
    'Какао',
  ];

  // Hardcoded list of units of measurement (fallback)
  final List<String> _dummyUnits = [
    'ст. ложка',
    'ч. ложка',
    'стакан',
    'мл',
    'л',
    'г',
    'кг',
    'шт',
    'зубчик',
    'по вкусу',
    'щепотка',
  ];

  // Method to get recipes
  Future<List<Recipe>> getRecipes() async {
    try {
      // Check if the device is connected to the internet
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        // Get recipes from the API
        final recipes = await _apiService.getRecipes();

        // Save recipes to the local database
        for (var recipe in recipes) {
          await _databaseService.saveRecipe(recipe);
        }

        return recipes;
      } else {
        // Get recipes from the local database
        return await _databaseService.getAllRecipes();
      }
    } catch (e) {
      // If there's an error, try to get recipes from the local database
      try {
        return await _databaseService.getAllRecipes();
      } catch (e) {
        // If that also fails, return the dummy recipes as a last resort
        return _dummyRecipes;
      }
    }
  }

  // Method to get favorite recipes
  Future<List<Recipe>> getFavoriteRecipes() async {
    try {
      // Check if the device is connected to the internet
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        // Get all recipes from the API
        final recipes = await _apiService.getRecipes();

        // Filter to get only favorites
        final favoriteRecipes = recipes.where((recipe) => recipe.isFavorite).toList();

        // Save recipes to the local database
        for (var recipe in recipes) {
          await _databaseService.saveRecipe(recipe);
        }

        return favoriteRecipes;
      } else {
        // Get favorite recipes from the local database
        return await _databaseService.getFavoriteRecipes();
      }
    } catch (e) {
      // If there's an error, try to get favorite recipes from the local database
      try {
        return await _databaseService.getFavoriteRecipes();
      } catch (e) {
        // If that also fails, return the dummy favorite recipes as a last resort
        return _dummyRecipes.where((recipe) => recipe.isFavorite).toList();
      }
    }
  }

  // Method to get ingredients
  Future<List<String>> getIngredients() async {
    // For now, we'll just return the hardcoded list
    // In a real app, this would come from the API or database
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyIngredients;
  }

  // Method to get units of measurement
  Future<List<String>> getUnits() async {
    // For now, we'll just return the hardcoded list
    // In a real app, this would come from the API or database
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyUnits;
  }

  // Method to save a new recipe
  Future<bool> saveRecipe(Recipe recipe) async {
    try {
      // Check if the device is connected to the internet
      final isConnected = await _connectivityService.isConnected();

      // Always save to the local database
      await _databaseService.saveRecipe(recipe);

      if (isConnected) {
        // If connected, also save to the API
        await _apiService.createRecipe(recipe);
      }

      return true;
    } catch (e) {
      // If there's an error saving to the API, at least we saved locally
      return false;
    }
  }

  // Method to toggle favorite status
  Future<bool> toggleFavorite(String recipeId) async {
    try {
      // Get the recipe from the local database
      final recipe = await _databaseService.getRecipeByUuid(recipeId);
      if (recipe == null) {
        return false;
      }

      // Toggle the favorite status locally
      final success = await _databaseService.toggleFavorite(recipeId);

      // Check if the device is connected to the internet
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        // If connected, also update on the API
        await _apiService.toggleFavorite(recipeId, !recipe.isFavorite);
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // Method to add a comment to a recipe
  Future<bool> addComment(String recipeId, Comment comment) async {
    try {
      // Get the recipe from the local database
      final recipe = await _databaseService.getRecipeByUuid(recipeId);
      if (recipe == null) {
        return false;
      }

      // Add the comment to the recipe
      final updatedComments = List<Comment>.from(recipe.comments)..add(comment);

      // Create a new recipe with the updated comments
      final updatedRecipe = Recipe(
        uuid: recipe.uuid,
        name: recipe.name,
        images: recipe.images,
        description: recipe.description,
        instructions: recipe.instructions,
        difficulty: recipe.difficulty,
        duration: recipe.duration,
        rating: recipe.rating,
        tags: recipe.tags,
        ingredients: recipe.ingredients,
        steps: recipe.steps,
        isFavorite: recipe.isFavorite,
        comments: updatedComments,
      );

      // Save the updated recipe to the local database
      await _databaseService.saveRecipe(updatedRecipe);

      // Check if the device is connected to the internet
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        // If connected, also update on the API
        await _apiService.addComment(recipeId, comment);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Method to update step completion status
  Future<bool> updateStepStatus(String recipeId, int stepIndex, bool isCompleted) async {
    try {
      // Get the recipe from the local database
      final recipe = await _databaseService.getRecipeByUuid(recipeId);
      if (recipe == null || stepIndex < 0 || stepIndex >= recipe.steps.length) {
        print('Invalid recipe or step index: recipeId=$recipeId, stepIndex=$stepIndex');
        return false;
      }

      // Update the step in the local database
      // In a real app, we need to update both the local database and the API
      final updatedSteps = List<RecipeStep>.from(recipe.steps);
      updatedSteps[stepIndex] = RecipeStep(
        description: recipe.steps[stepIndex].description,
        duration: recipe.steps[stepIndex].duration,
        isCompleted: isCompleted,
      );

      // Create a new recipe with the updated steps
      final updatedRecipe = Recipe(
        uuid: recipe.uuid,
        name: recipe.name,
        images: recipe.images,
        description: recipe.description,
        instructions: recipe.instructions,
        difficulty: recipe.difficulty,
        duration: recipe.duration,
        rating: recipe.rating,
        tags: recipe.tags,
        ingredients: recipe.ingredients,
        steps: updatedSteps,
        isFavorite: recipe.isFavorite,
        comments: recipe.comments,
      );

      // Save the updated recipe to the local database
      await _databaseService.saveRecipe(updatedRecipe);

      // Check if the device is connected to the internet
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        try {
          // If connected, also update on the API
          // In a real app, we would use the step ID from the database
          // For now, we'll use the step index as the ID
          await _apiService.updateStep(recipeId, stepIndex, isCompleted);
          print('Successfully updated step $stepIndex for recipe $recipeId on API');
        } catch (e) {
          // If there's an error updating on the API, log it but don't fail the operation
          // since we've already updated the local database
          print('Error updating step on API: $e');
        }
      }

      return true;
    } catch (e) {
      print('Error updating step status: $e');
      return false;
    }
  }

  // Hardcoded list of recipes (static to be shared across instances)
  static final List<Recipe> _dummyRecipes = [
    Recipe(
      uuid: '1',
      name: 'Спагетти Карбонара',
      images: 'https://images.unsplash.com/photo-1588013273468-315fd88ea34c', // Ensure this is a direct image URL
      description: 'Классическое итальянское блюдо из спагетти с соусом на основе яиц, сыра, гуанчиале и черного перца.',
      instructions: '...',
      difficulty: 2,
      duration: '30 минут', // Added duration
      rating: 5,
      tags: ['Итальянская кухня', 'Паста', 'Ужин'],
      ingredients: [
        Ingredient(name: 'Спагетти', quantity: '400', unit: 'г'),
        Ingredient(name: 'Гуанчиале', quantity: '150', unit: 'г'),
        Ingredient(name: 'Яйца', quantity: '4', unit: 'шт'),
        Ingredient(name: 'Сыр пармезан', quantity: '50', unit: 'г'),
        Ingredient(name: 'Черный перец', quantity: '1', unit: 'ч. ложка'),
        Ingredient(name: 'Соль', quantity: '1', unit: 'по вкусу'),
      ],
      steps: [
        RecipeStep(
          description: 'Отварите спагетти в подсоленной воде до состояния аль денте.',
          duration: '10:00',
        ),
        RecipeStep(
          description: 'Нарежьте гуанчиале небольшими кубиками и обжарьте на сковороде до золотистого цвета.',
          duration: '05:00',
        ),
        RecipeStep(
          description: 'Смешайте яйца, тертый пармезан и черный перец в миске.',
          duration: '03:00',
        ),
        RecipeStep(
          description: 'Добавьте горячие спагетти к гуанчиале, перемешайте и снимите с огня.',
          duration: '02:00',
        ),
        RecipeStep(
          description: 'Влейте яичную смесь и быстро перемешайте, чтобы получился кремовый соус.',
          duration: '01:00',
        ),
        RecipeStep(
          description: 'Подавайте сразу же, посыпав дополнительным пармезаном и черным перцем.',
          duration: '01:00',
        ),
      ],
    ),
    Recipe(
      uuid: '2',
      name: 'Борщ',
      images: 'https://images.unsplash.com/photo-1594756202469-9ff9799b2e4e',
      description: 'Традиционный восточноевропейский суп на основе свеклы, который придает ему характерный красный цвет.',
      instructions: '...',
      difficulty: 3,
      duration: '1 час 15 минут', // Added duration
      rating: 5,
      tags: ['Русская кухня', 'Суп', 'Обед'],
    ),
    Recipe(
      uuid: '3',
      name: 'Греческий салат',
      images: 'https://images.unsplash.com/photo-1551248429-40975aa4de74',
      description: 'Свежий салат из помидоров, огурцов, болгарского перца, красного лука, оливок и сыра фета с оливковым маслом.',
      instructions: '...',
      difficulty: 1,
      duration: '15 минут', // Added duration
      rating: 4,
      tags: ['Греческая кухня', 'Салат', 'Вегетарианское'],
    ),
    Recipe(
      uuid: '4',
      name: 'Суши Филадельфия',
      images: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c',
      description: 'Популярные роллы с лососем, сливочным сыром, авокадо и огурцом.',
      instructions: '...',
      difficulty: 4,
      duration: '45 минут', // Added duration
      rating: 5,
      tags: ['Японская кухня', 'Суши', 'Рыба'],
    ),
    Recipe(
      uuid: '5',
      name: 'Тирамису',
      images: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9',
      description: 'Классический итальянский десерт на основе маскарпоне, кофе и печенья савоярди.',
      instructions: '...',
      difficulty: 3,
      duration: '30 минут', // Added duration
      rating: 5,
      tags: ['Итальянская кухня', 'Десерт', 'Кофе'],
    ),
  ];
}
