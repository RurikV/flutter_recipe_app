import 'package:flutter/material.dart';
import 'models/recipe.dart';
import 'data/api_service.dart';

// This is a simple manual test script to verify that our fix for the duration field works correctly.
// To run this script, you can use the following command:
// flutter run -t lib/test_recipe_creation.dart

void main() {
  runApp(const TestRecipeCreationApp());
}

class TestRecipeCreationApp extends StatelessWidget {
  const TestRecipeCreationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Recipe Creation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TestRecipeCreationScreen(),
    );
  }
}

class TestRecipeCreationScreen extends StatefulWidget {
  const TestRecipeCreationScreen({super.key});

  @override
  State<TestRecipeCreationScreen> createState() => _TestRecipeCreationScreenState();
}

class _TestRecipeCreationScreenState extends State<TestRecipeCreationScreen> {
  final ApiService _apiService = ApiService();
  String _testResults = 'Press the buttons below to run the tests.';
  bool _isLoading = false;

  Future<void> _testCreateRecipeWithValidData() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Running test: Create recipe with valid data...';
    });

    try {
      // Create a recipe with valid data
      final recipe = Recipe(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Test Recipe ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '30 min',
        rating: 0,
        tags: [],
        ingredients: [],
        steps: [],
      );

      // Try to save the recipe
      final createdRecipe = await _apiService.createRecipe(recipe);
      
      setState(() {
        _testResults = 'Test passed: Recipe created successfully!\n'
            'Recipe ID: ${createdRecipe.uuid}\n'
            'Recipe Name: ${createdRecipe.name}';
      });
    } catch (e) {
      setState(() {
        _testResults = 'Test failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCreateRecipeWithEmptyDuration() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Running test: Create recipe with empty duration...';
    });

    try {
      // Create a recipe with empty duration
      final recipe = Recipe(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Test Recipe Empty Duration ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: '', // Empty duration
        rating: 0,
        tags: [],
        ingredients: [],
        steps: [],
      );

      // Try to save the recipe
      final createdRecipe = await _apiService.createRecipe(recipe);
      
      setState(() {
        _testResults = 'Test passed: Recipe with empty duration created successfully!\n'
            'Recipe ID: ${createdRecipe.uuid}\n'
            'Recipe Name: ${createdRecipe.name}';
      });
    } catch (e) {
      setState(() {
        _testResults = 'Test failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCreateRecipeWithNonNumericDuration() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Running test: Create recipe with non-numeric duration...';
    });

    try {
      // Create a recipe with non-numeric duration
      final recipe = Recipe(
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Test Recipe Non-Numeric Duration ${DateTime.now().millisecondsSinceEpoch}',
        images: 'https://via.placeholder.com/400x300?text=Test+Recipe',
        description: 'Test description',
        instructions: 'Test instructions',
        difficulty: 2,
        duration: 'about an hour', // Non-numeric duration
        rating: 0,
        tags: [],
        ingredients: [],
        steps: [],
      );

      // Try to save the recipe
      final createdRecipe = await _apiService.createRecipe(recipe);
      
      setState(() {
        _testResults = 'Test passed: Recipe with non-numeric duration created successfully!\n'
            'Recipe ID: ${createdRecipe.uuid}\n'
            'Recipe Name: ${createdRecipe.name}';
      });
    } catch (e) {
      setState(() {
        _testResults = 'Test failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Recipe Creation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Recipe Creation Tests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_testResults),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testCreateRecipeWithValidData,
              child: const Text('Test: Create Recipe with Valid Data'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testCreateRecipeWithEmptyDuration,
              child: const Text('Test: Create Recipe with Empty Duration'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testCreateRecipeWithNonNumericDuration,
              child: const Text('Test: Create Recipe with Non-Numeric Duration'),
            ),
          ],
        ),
      ),
    );
  }
}