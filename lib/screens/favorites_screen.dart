import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../../models/recipe.dart';
import '../domain/usecases/recipe_manager.dart';
import '../widgets/recipe/recipe_list.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final RecipeManager _recipeManager = RecipeManager();
  late Future<List<Recipe>> _favoriteRecipesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavoriteRecipes();
  }

  void _loadFavoriteRecipes() {
    setState(() {
      _favoriteRecipesFuture = _recipeManager.getFavoriteRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFECECEC), // Background color as per design
      appBar: AppBar(
        title: Text(l10n.favorites),
        centerTitle: true,
        backgroundColor: const Color(0xFFECECEC), // Match background color
        elevation: 0, // No shadow
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: SizedBox(
              width: orientation == Orientation.landscape
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width,
              child: FutureBuilder<List<Recipe>>(
                future: _favoriteRecipesFuture,
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
                            l10n.errorLoadingFavorites,
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
                            Icons.favorite_border,
                            color: Colors.grey,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noFavoritesAvailable,
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
