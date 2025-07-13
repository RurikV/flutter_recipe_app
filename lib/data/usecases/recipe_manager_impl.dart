import 'recipe_manager.dart';
import '../models/recipe.dart';
import '../models/comment.dart';
import '../models/ingredient.dart';
import '../models/recipe_step.dart';
import '../repositories/recipe_repository.dart';

/// Implementation of the RecipeManager interface
class RecipeManagerImpl implements RecipeManager {
  final RecipeRepository _recipeRepository;

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

  /// Constructor with required RecipeRepository dependency
  RecipeManagerImpl({
    required RecipeRepository recipeRepository,
  }) : _recipeRepository = recipeRepository;

  @override
  Future<List<Recipe>> getRecipes() async {
    try {
      // Use the repository to get recipes (now returns domain entities)
      return await _recipeRepository.getRecipes();
    } catch (e) {
      print('Error in getRecipes: $e');
      // Rethrow the error instead of falling back to dummy recipes
      throw Exception('Failed to get recipes: $e');
    }
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    try {
      // Use the repository to get favorite recipes
      return await _recipeRepository.getFavoriteRecipes();
    } catch (e) {
      print('Error in getFavoriteRecipes: $e');
      // Rethrow the error instead of falling back to dummy recipes
      throw Exception('Failed to get favorite recipes: $e');
    }
  }

  @override
  Future<Recipe?> getRecipeByUuid(String uuid) async {
    print('[DEBUG_LOG] RecipeManagerImpl: getRecipeByUuid called with UUID: $uuid');

    try {
      print('[DEBUG_LOG] RecipeManagerImpl: Calling repository.getRecipeByUuid($uuid)');

      // Use the repository to get detailed recipe information
      final recipe = await _recipeRepository.getRecipeByUuid(uuid);

      if (recipe != null) {
        print('[DEBUG_LOG] RecipeManagerImpl: Repository returned recipe:');
        print('[DEBUG_LOG] - UUID: ${recipe.uuid}');
        print('[DEBUG_LOG] - Name: ${recipe.name}');
        print('[DEBUG_LOG] - Duration: ${recipe.duration}');
        print('[DEBUG_LOG] - Ingredients count: ${recipe.ingredients.length}');
        print('[DEBUG_LOG] - Steps count: ${recipe.steps.length}');

        if (recipe.ingredients.isNotEmpty) {
          print('[DEBUG_LOG] RecipeManagerImpl: Ingredients from repository:');
          for (int i = 0; i < recipe.ingredients.length; i++) {
            final ingredient = recipe.ingredients[i];
            print('[DEBUG_LOG]   ${i + 1}. ${ingredient.name} - ${ingredient.quantity} ${ingredient.unit}');
          }
        } else {
          print('[DEBUG_LOG] RecipeManagerImpl: ⚠️ Repository returned recipe with NO INGREDIENTS!');
        }

        if (recipe.steps.isNotEmpty) {
          print('[DEBUG_LOG] RecipeManagerImpl: Steps from repository:');
          for (int i = 0; i < recipe.steps.length; i++) {
            final step = recipe.steps[i];
            print('[DEBUG_LOG]   ${i + 1}. ${step.name} (${step.duration} min)');
          }
        } else {
          print('[DEBUG_LOG] RecipeManagerImpl: ⚠️ Repository returned recipe with NO STEPS!');
        }

        return recipe;
      } else {
        print('[DEBUG_LOG] RecipeManagerImpl: ❌ Repository returned NULL recipe!');
        return null;
      }
    } catch (e) {
      print('[DEBUG_LOG] RecipeManagerImpl: ❌ Error in getRecipeByUuid: $e');
      print('[DEBUG_LOG] RecipeManagerImpl: Error stack trace: ${StackTrace.current}');
      // Rethrow the error
      throw Exception('Failed to get recipe by UUID: $e');
    }
  }

  @override
  Future<List<String>> getIngredients() async {
    try {
      // Use the repository to get available ingredients
      return await _recipeRepository.getAvailableIngredients();
    } catch (e) {
      print('Error in getIngredients: $e');
      // If all else fails, return the dummy ingredients as a last resort
      return _dummyIngredients;
    }
  }

  @override
  Future<List<String>> getUnits() async {
    try {
      // Use the repository to get available units
      return await _recipeRepository.getAvailableUnits();
    } catch (e) {
      print('Error in getUnits: $e');
      // If all else fails, return the dummy units as a last resort
      return _dummyUnits;
    }
  }

  @override
  Future<bool> saveRecipe(Recipe recipe) async {
    try {
      // Use the repository to save the recipe
      await _recipeRepository.saveRecipe(recipe);
      return true;
    } catch (e) {
      print('Error in saveRecipe: $e');
      return false;
    }
  }

  @override
  Future<bool> toggleFavorite(String recipeId) async {
    try {
      // Use the repository to toggle favorite status
      await _recipeRepository.toggleFavorite(recipeId);
      return true;
    } catch (e) {
      print('Error in toggleFavorite: $e');
      return false;
    }
  }

  @override
  Future<bool> addComment(String recipeId, Comment comment) async {
    try {
      // Use the repository to add a comment
      await _recipeRepository.addComment(recipeId, comment);
      return true;
    } catch (e) {
      print('Error in addComment: $e');
      return false;
    }
  }

  @override
  Future<bool> updateStepStatus(String recipeId, int stepIndex, bool isCompleted) async {
    try {
      // Get the recipe from the repository
      final recipe = await _recipeRepository.getRecipeByUuid(recipeId);
      if (recipe == null || stepIndex < 0 || stepIndex >= recipe.steps.length) {
        print('Invalid recipe or step index: recipeId=$recipeId, stepIndex=$stepIndex');
        return false;
      }

      // Update the step in the recipe
      final updatedSteps = List<RecipeStep>.from(recipe.steps);
      updatedSteps[stepIndex] = RecipeStep(
        id: recipe.steps[stepIndex].id,
        name: recipe.steps[stepIndex].name,
        duration: recipe.steps[stepIndex].duration,
        stepLinks: recipe.steps[stepIndex].stepLinks,
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

      // Update the recipe in the repository
      await _recipeRepository.updateRecipe(updatedRecipe);
      return true;
    } catch (e) {
      print('Error updating step status: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteRecipe(String recipeId) async {
    try {
      // Use the repository to delete the recipe
      await _recipeRepository.deleteRecipe(recipeId);
      return true;
    } catch (e) {
      print('Error in deleteRecipe: $e');
      return false;
    }
  }

  // Method to get dummy recipes for testing or initial data
  static List<Recipe> getDummyRecipes() {
    return _dummyRecipes;
  }

  // Hardcoded list of recipes (static to be shared across instances)
  static final List<Recipe> _dummyRecipes = [
    Recipe(
      uuid: '1',
      name: 'Спагетти Карбонара',
      images: 'https://images.unsplash.com/photo-1588013273468-315fd88ea34c',
      description: 'Классическое итальянское блюдо из спагетти с соусом на основе яиц, сыра, гуанчиале и черного перца.',
      instructions: '...',
      difficulty: 2,
      duration: '30 минут',
      rating: 5,
      tags: ['Итальянская кухня', 'Паста', 'Ужин'],
      ingredients: [
        Ingredient.simple(name: 'Спагетти', quantity: '400', unit: 'г'),
        Ingredient.simple(name: 'Гуанчиале', quantity: '150', unit: 'г'),
        Ingredient.simple(name: 'Яйца', quantity: '4', unit: 'шт'),
        Ingredient.simple(name: 'Сыр пармезан', quantity: '50', unit: 'г'),
        Ingredient.simple(name: 'Черный перец', quantity: '1', unit: 'ч. ложка'),
        Ingredient.simple(name: 'Соль', quantity: '1', unit: 'по вкусу'),
      ],
      steps: [
        RecipeStep.simple(
          description: 'Отварите спагетти в подсоленной воде до состояния аль денте.',
          duration: '10',
        ),
        RecipeStep.simple(
          description: 'Нарежьте гуанчиале небольшими кубиками и обжарьте на сковороде до золотистого цвета.',
          duration: '5',
        ),
        RecipeStep.simple(
          description: 'Смешайте яйца, тертый пармезан и черный перец в миске.',
          duration: '3',
        ),
        RecipeStep.simple(
          description: 'Добавьте горячие спагетти к гуанчиале, перемешайте и снимите с огня.',
          duration: '2',
        ),
        RecipeStep.simple(
          description: 'Влейте яичную смесь и быстро перемешайте, чтобы получился кремовый соус.',
          duration: '1',
        ),
        RecipeStep.simple(
          description: 'Подавайте сразу же, посыпав дополнительным пармезаном и черным перцем.',
          duration: '1',
        ),
      ],
      isFavorite: false,
      comments: [],
    ),
    Recipe(
      uuid: '2',
      name: 'Борщ',
      images: 'https://images.unsplash.com/photo-1594756202469-9ff9799b2e4e',
      description: 'Традиционный восточноевропейский суп на основе свеклы, который придает ему характерный красный цвет.',
      instructions: '...',
      difficulty: 3,
      duration: '1 час 15 минут',
      rating: 5,
      tags: ['Русская кухня', 'Суп', 'Обед'],
      ingredients: [],
      steps: [],
      isFavorite: false,
      comments: [],
    ),
    Recipe(
      uuid: '3',
      name: 'Греческий салат',
      images: 'https://images.unsplash.com/photo-1551248429-40975aa4de74',
      description: 'Свежий салат из помидоров, огурцов, болгарского перца, красного лука, оливок и сыра фета с оливковым маслом.',
      instructions: '...',
      difficulty: 1,
      duration: '15 минут',
      rating: 4,
      tags: ['Греческая кухня', 'Салат', 'Вегетарианское'],
      ingredients: [],
      steps: [],
      isFavorite: false,
      comments: [],
    ),
    Recipe(
      uuid: '4',
      name: 'Суши Филадельфия',
      images: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c',
      description: 'Популярные роллы с лососем, сливочным сыром, авокадо и огурцом.',
      instructions: '...',
      difficulty: 4,
      duration: '45 минут',
      rating: 5,
      tags: ['Японская кухня', 'Суши', 'Рыба'],
      ingredients: [],
      steps: [],
      isFavorite: false,
      comments: [],
    ),
    Recipe(
      uuid: '5',
      name: 'Тирамису',
      images: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9',
      description: 'Классический итальянский десерт на основе маскарпоне, кофе и печенья савоярди.',
      instructions: '...',
      difficulty: 3,
      duration: '30 минут',
      rating: 5,
      tags: ['Итальянская кухня', 'Десерт', 'Кофе'],
      ingredients: [],
      steps: [],
      isFavorite: false,
      comments: [],
    ),
  ];
}
