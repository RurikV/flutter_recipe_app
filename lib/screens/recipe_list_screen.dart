import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../l10n/app_localizations.dart';
import '../../../data/models/recipe.dart';
import '../utils/page_transition.dart';
import '../widgets/recipe/recipe_list.dart';
import '../widgets/navigation/auth_bottom_navigation_bar.dart';
import 'add_recipe_screen.dart';
import '../redux/app_state.dart';
import '../redux/actions.dart';

class RecipeListScreen extends StatefulWidget {
  final bool loadRecipesOnInit;

  const RecipeListScreen({
    super.key,
    this.loadRecipesOnInit = true,
  });

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  void _loadRecipes() {
    // Dispatch action to load recipes
    StoreProvider.of<AppState>(context, listen: false)
        .dispatch(LoadRecipesAction());
  }

  void _loadFavorites() {
    // Dispatch action to load favorite recipes
    StoreProvider.of<AppState>(context, listen: false)
        .dispatch(LoadFavoriteRecipesAction());
  }

  @override
  void initState() {
    super.initState();
    // Load both recipes and favorites when the screen is first displayed
    // Only if loadRecipesOnInit is true (default)
    if (widget.loadRecipesOnInit) {
      Future.microtask(() {
        _loadRecipes();
        _loadFavorites();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? lookupAppLocalizations(const Locale('en'));

    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.isAuthenticated,
      builder: (context, isAuthenticated) {
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
          // Show AuthBottomNavigationBar only for non-authenticated users
          bottomNavigationBar: !isAuthenticated ? const AuthBottomNavigationBar(isLoginActive: false) : null,
          body: OrientationBuilder(
            builder: (context, orientation) {
              return Center(
                child: SizedBox(
                  width: orientation == Orientation.landscape
                      ? MediaQuery.of(context).size.width * 0.5
                      : MediaQuery.of(context).size.width,
                  child: StoreConnector<AppState, _RecipeListViewModel>(
                    converter: (store) => _RecipeListViewModel.fromStore(store),
                    builder: (context, viewModel) {
                      if (viewModel.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (viewModel.error.isNotEmpty) {
                        // Log error to console when displaying to user
                        print('[UI_ERROR] Displaying error in RecipeListScreen: ${viewModel.error}');
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
                                viewModel.error,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } else if (viewModel.recipes.isEmpty) {
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
                        return RecipeList(recipes: viewModel.recipes);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}


// ViewModel for the RecipeListScreen
class _RecipeListViewModel {
  final List<Recipe> recipes;
  final bool isLoading;
  final String error;

  _RecipeListViewModel({
    required this.recipes,
    required this.isLoading,
    required this.error,
  });

  // Factory method to create a ViewModel from the Redux store
  static _RecipeListViewModel fromStore(store) {
    return _RecipeListViewModel(
      recipes: store.state.recipes,
      isLoading: store.state.isLoading,
      error: store.state.error,
    );
  }
}
