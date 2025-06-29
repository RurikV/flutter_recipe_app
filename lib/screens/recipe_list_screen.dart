import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../../models/recipe.dart';
import '../domain/usecases/recipe_manager.dart';
import '../utils/page_transition.dart';
import '../widgets/recipe/recipe_list.dart';
import 'add_recipe_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final RecipeManager _recipeManager = RecipeManager();
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    setState(() {
      _recipesFuture = _recipeManager.getRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFECECEC), // Background color as per design
      appBar: AppBar(
        title: Text(l10n.recipes),
        centerTitle: true,
        backgroundColor: const Color(0xFFECECEC), // Match background color
        elevation: 0, // No shadow
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            CustomPageRoute(
              page: AddRecipeScreen(
                onRecipeAdded: _loadRecipes,
              ),
              transitionType: TransitionType.fadeAndScale,
            ),
          );
        },
        backgroundColor: const Color(0xFF2ECC71),
        child: const Icon(Icons.add),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: SizedBox(
              width: orientation == Orientation.landscape
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width,
              child: FutureBuilder<List<Recipe>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.errorLoadingRecipes,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.no_food,
                    color: Colors.grey,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noRecipesAvailable,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          } else {
            return RecipeList(recipes: snapshot.data!);
          }
        },
              ),
            ),
          );
        },
      ),
    );
  }
}
