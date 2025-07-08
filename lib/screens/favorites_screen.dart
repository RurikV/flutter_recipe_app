import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../l10n/app_localizations.dart';
import '../../../data/models/recipe.dart';
import '../widgets/recipe/recipe_list.dart';
import '../redux/app_state.dart';
import '../redux/actions.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {

  void _loadFavorites() {
    // Dispatch action to load favorite recipes
    StoreProvider.of<AppState>(context, listen: false)
        .dispatch(LoadFavoriteRecipesAction());
  }

  @override
  void initState() {
    super.initState();
    // Load favorites when the screen is first displayed
    Future.microtask(() => _loadFavorites());
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
              child: StoreConnector<AppState, _FavoritesViewModel>(
                converter: (store) => _FavoritesViewModel.fromStore(store),
                builder: (context, viewModel) {
                  if (viewModel.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (viewModel.error.isNotEmpty) {
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
                            viewModel.error,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else if (viewModel.favoriteRecipes.isEmpty) {
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
                    return RecipeList(recipes: viewModel.favoriteRecipes);
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


// ViewModel for the FavoritesScreen
class _FavoritesViewModel {
  final List<Recipe> favoriteRecipes;
  final bool isLoading;
  final String error;

  _FavoritesViewModel({
    required this.favoriteRecipes,
    required this.isLoading,
    required this.error,
  });

  // Factory method to create a ViewModel from the Redux store
  static _FavoritesViewModel fromStore(store) {
    return _FavoritesViewModel(
      favoriteRecipes: store.state.favoriteRecipes,
      isLoading: store.state.isLoading,
      error: store.state.error,
    );
  }
}
