import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/recipe_step.dart';
import '../models/comment.dart';

class RecipeManager {
  // Regular class constructor
  RecipeManager();

  // Hardcoded list of ingredients
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

  // Hardcoded list of units of measurement
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

  // Method to get recipes (currently returns hardcoded data)
  Future<List<Recipe>> getRecipes() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _dummyRecipes;
  }

  // Method to get favorite recipes
  Future<List<Recipe>> getFavoriteRecipes() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter recipes to return only favorites
    return _dummyRecipes.where((recipe) => recipe.isFavorite).toList();
  }

  // Method to get ingredients (currently returns hardcoded data)
  Future<List<String>> getIngredients() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    return _dummyIngredients;
  }

  // Method to get units of measurement (currently returns hardcoded data)
  Future<List<String>> getUnits() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    return _dummyUnits;
  }

  // Method to save a new recipe
  Future<bool> saveRecipe(Recipe recipe) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Add the recipe to the list
    _dummyRecipes.add(recipe);

    return true;
  }

  // Method to toggle favorite status
  Future<bool> toggleFavorite(String recipeId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Find the recipe by ID
    final recipeIndex = _dummyRecipes.indexWhere((recipe) => recipe.uuid == recipeId);
    if (recipeIndex == -1) {
      return false;
    }

    // Toggle the favorite status
    _dummyRecipes[recipeIndex].isFavorite = !_dummyRecipes[recipeIndex].isFavorite;

    return true;
  }

  // Method to add a comment to a recipe
  Future<bool> addComment(String recipeId, Comment comment) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Find the recipe by ID
    final recipeIndex = _dummyRecipes.indexWhere((recipe) => recipe.uuid == recipeId);
    if (recipeIndex == -1) {
      return false;
    }

    // Add the comment to the recipe
    final recipe = _dummyRecipes[recipeIndex];
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

    // Replace the old recipe with the updated one
    _dummyRecipes[recipeIndex] = updatedRecipe;

    return true;
  }

  // Method to update step completion status
  Future<bool> updateStepStatus(String recipeId, int stepIndex, bool isCompleted) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Find the recipe by ID
    final recipeIndex = _dummyRecipes.indexWhere((recipe) => recipe.uuid == recipeId);
    if (recipeIndex == -1 || stepIndex < 0 || stepIndex >= _dummyRecipes[recipeIndex].steps.length) {
      return false;
    }

    // Update the step completion status
    _dummyRecipes[recipeIndex].steps[stepIndex].isCompleted = isCompleted;

    return true;
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
