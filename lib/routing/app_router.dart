import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/recipe_list_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/add_recipe_screen.dart';
import '../screens/recipe_detail_screen.dart';
import '../screens/gallery_screen.dart';
import '../screens/profile_screen.dart';
import '../redux/app_state.dart';
import '../data/models/recipe.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    // Authentication routes
    AutoRoute(
      page: LoginRoute.page,
      path: '/login',
      initial: false,
    ),
    AutoRoute(
      page: RegistrationRoute.page,
      path: '/registration',
    ),

    // Protected routes (require authentication)
    AutoRoute(
      page: HomeWrapperRoute.page,
      path: '/',
      initial: true,
      children: [
        AutoRoute(
          page: HomeRoute.page,
          path: 'home',
          initial: true,
        ),
        AutoRoute(
          page: RecipeListRoute.page,
          path: 'recipes',
        ),
        AutoRoute(
          page: FavoritesRoute.page,
          path: 'favorites',
        ),
        AutoRoute(
          page: AddRecipeRoute.page,
          path: 'add-recipe',
        ),
        AutoRoute(
          page: ProfileRoute.page,
          path: 'profile',
        ),
      ],
    ),

    // Detail routes (programmatic navigation only)
    AutoRoute(
      page: RecipeDetailRoute.page,
      path: '/recipe-detail',
    ),
    AutoRoute(
      page: GalleryRoute.page,
      path: '/gallery/:recipeUuid',
    ),
  ];
}

// Route pages
@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}

@RoutePage()
class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RegistrationScreen();
  }
}

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

@RoutePage()
class RecipeListPage extends StatelessWidget {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RecipeListScreen();
  }
}

@RoutePage()
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FavoritesScreen();
  }
}

@RoutePage()
class AddRecipePage extends StatelessWidget {
  const AddRecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AddRecipeScreen(
      onRecipeAdded: () {
        // Callback when recipe is added - could trigger a refresh or navigation
        // For now, just a simple callback
      },
    );
  }
}

@RoutePage()
class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return RecipeDetailScreen(recipe: recipe);
  }
}

@RoutePage()
class GalleryPage extends StatelessWidget {
  final String recipeUuid;
  final String recipeName;

  const GalleryPage({
    super.key,
    @pathParam required this.recipeUuid,
    @queryParam required this.recipeName,
  });

  @override
  Widget build(BuildContext context) {
    return GalleryScreen(
      recipeUuid: recipeUuid,
      recipeName: recipeName,
    );
  }
}

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}

// Wrapper page that handles authentication guard
@RoutePage()
class HomeWrapperPage extends StatelessWidget {
  const HomeWrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.isAuthenticated,
      builder: (context, isAuthenticated) {
        if (!isAuthenticated) {
          // Redirect to login if not authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.router.navigate(const LoginRoute());
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const AutoRouter();
      },
    );
  }
}
