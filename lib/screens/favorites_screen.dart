import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../l10n/app_localizations.dart';
import '../../../data/models/recipe.dart';
import '../widgets/recipe/recipe_list.dart';
import '../redux/app_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {

  @override
  void initState() {
    super.initState();
    // Favorites should already be available in Redux state from previous loads
    // No need to reload them here as it can cause them to disappear if the operation fails
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
                  // Show loading indicator only if we have no favorites and are loading
                  if (viewModel.isLoading && viewModel.favoriteRecipes.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } 
                  // Show error only if we have no favorites and there's an error
                  else if (viewModel.error.isNotEmpty && viewModel.favoriteRecipes.isEmpty) {
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
                  } 
                  // Show "no favorites" message only if we're not loading and have no favorites
                  else if (viewModel.favoriteRecipes.isEmpty && !viewModel.isLoading) {
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
                  } 
                  // Show favorites list with optional error banner
                  else {
                    return Column(
                      children: [
                        // Show error banner if there's an error but we have favorites to show
                        if (viewModel.error.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8.0),
                            color: Colors.orange.withValues(alpha: 0.1),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.orange, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Unable to refresh favorites',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Show loading indicator at top if refreshing
                        if (viewModel.isLoading)
                          const LinearProgressIndicator(),
                        // Show the favorites list
                        Expanded(
                          child: RecipeList(recipes: viewModel.favoriteRecipes),
                        ),
                      ],
                    );
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
