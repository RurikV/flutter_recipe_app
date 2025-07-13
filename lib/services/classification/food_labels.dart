import 'dart:math';

/// Centralized food labels for object detection services
/// This eliminates duplication and focuses on food items appropriate for a recipe application
class FoodLabels {
  static const List<String> labels = [
    // Fruits
    'apple',
    'banana',
    'orange',
    'strawberry',
    'blueberry',
    'grape',
    'lemon',
    'lime',
    'pineapple',
    'mango',
    'avocado',
    'watermelon',

    // Vegetables
    'broccoli',
    'carrot',
    'potato',
    'tomato',
    'onion',
    'garlic',
    'bell pepper',
    'cucumber',
    'lettuce',
    'spinach',
    'mushroom',
    'corn',

    // Proteins
    'chicken',
    'beef',
    'pork',
    'fish',
    'salmon',
    'shrimp',
    'egg',
    'tofu',
    'beans',
    'nuts',

    // Grains & Starches
    'rice',
    'pasta',
    'bread',
    'quinoa',
    'oats',
    'flour',

    // Dairy
    'milk',
    'cheese',
    'yogurt',
    'butter',

    // Prepared Foods
    'pizza',
    'sandwich',
    'salad',
    'soup',
    'pasta dish',
    'stir fry',

    // Baked Goods & Desserts
    'cake',
    'cookie',
    'muffin',
    'donut',
    'pie',
    'bread loaf',

    // Beverages
    'coffee',
    'tea',
    'juice',
    'smoothie',

    // Herbs & Spices
    'basil',
    'parsley',
    'cilantro',
    'rosemary',
    'thyme',
    'ginger',

    // Cooking Essentials
    'olive oil',
    'vinegar',
    'salt',
    'pepper',
    'honey',
    'sugar',
  ];

  /// Get a random subset of labels for mock detection
  static List<String> getRandomSubset(int count, [int? seed]) {
    final random = seed != null ? Random(seed) : Random();
    final shuffled = List<String>.from(labels)..shuffle(random);
    return shuffled.take(count).toList();
  }

  /// Get labels by category
  static List<String> getFruits() {
    return labels.sublist(0, 12);
  }

  static List<String> getVegetables() {
    return labels.sublist(12, 24);
  }

  static List<String> getProteins() {
    return labels.sublist(24, 34);
  }

  static List<String> getGrains() {
    return labels.sublist(34, 40);
  }

  static List<String> getDairy() {
    return labels.sublist(40, 44);
  }

  static List<String> getPreparedFoods() {
    return labels.sublist(44, 50);
  }

  static List<String> getBakedGoods() {
    return labels.sublist(50, 56);
  }

  static List<String> getBeverages() {
    return labels.sublist(56, 60);
  }

  static List<String> getHerbsAndSpices() {
    return labels.sublist(60, 66);
  }

  static List<String> getCookingEssentials() {
    return labels.sublist(66);
  }
}
