import '../models/recipe.dart';

class RecipeManager {
  // Regular class constructor
  RecipeManager();

  // Method to get recipes (currently returns hardcoded data)
  Future<List<Recipe>> getRecipes() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _dummyRecipes;
  }

  // Hardcoded list of recipes
  final List<Recipe> _dummyRecipes = [
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
