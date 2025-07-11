// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter();

  @override
  final Map<String, PageFactory> pagesMap = {
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginPage(),
      );
    },
    RegistrationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RegistrationPage(),
      );
    },
    HomeWrapperRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeWrapperPage(),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomePage(),
      );
    },
    RecipeListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RecipeListPage(),
      );
    },
    FavoritesRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FavoritesPage(),
      );
    },
    AddRecipeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AddRecipePage(),
      );
    },
    ProfileRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfilePage(),
      );
    },
    RecipeDetailRoute.name: (routeData) {
      final args = routeData.argsAs<RecipeDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: RecipeDetailPage(
          key: args.key,
          recipe: args.recipe,
        ),
      );
    },
    GalleryRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final queryParams = routeData.queryParams;
      final args = routeData.argsAs<GalleryRouteArgs>(
        orElse: () => GalleryRouteArgs(
          recipeUuid: pathParams.optString('recipeUuid') ?? '',
          recipeName: queryParams.optString('recipeName') ?? '',
        ),
      );
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: GalleryPage(
          key: args.key,
          recipeUuid: args.recipeUuid,
          recipeName: args.recipeName,
        ),
      );
    },
  };
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [RegistrationPage]
class RegistrationRoute extends PageRouteInfo<void> {
  const RegistrationRoute({List<PageRouteInfo>? children})
      : super(
          RegistrationRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegistrationRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomeWrapperPage]
class HomeWrapperRoute extends PageRouteInfo<void> {
  const HomeWrapperRoute({List<PageRouteInfo>? children})
      : super(
          HomeWrapperRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeWrapperRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [RecipeListPage]
class RecipeListRoute extends PageRouteInfo<void> {
  const RecipeListRoute({List<PageRouteInfo>? children})
      : super(
          RecipeListRoute.name,
          initialChildren: children,
        );

  static const String name = 'RecipeListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [FavoritesPage]
class FavoritesRoute extends PageRouteInfo<void> {
  const FavoritesRoute({List<PageRouteInfo>? children})
      : super(
          FavoritesRoute.name,
          initialChildren: children,
        );

  static const String name = 'FavoritesRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AddRecipePage]
class AddRecipeRoute extends PageRouteInfo<void> {
  const AddRecipeRoute({List<PageRouteInfo>? children})
      : super(
          AddRecipeRoute.name,
          initialChildren: children,
        );

  static const String name = 'AddRecipeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [RecipeDetailPage]
class RecipeDetailRoute extends PageRouteInfo<RecipeDetailRouteArgs> {
  RecipeDetailRoute({
    Key? key,
    required Recipe recipe,
    List<PageRouteInfo>? children,
  }) : super(
          RecipeDetailRoute.name,
          args: RecipeDetailRouteArgs(
            key: key,
            recipe: recipe,
          ),
          initialChildren: children,
        );

  static const String name = 'RecipeDetailRoute';

  static const PageInfo<RecipeDetailRouteArgs> page = PageInfo<RecipeDetailRouteArgs>(name);
}

class RecipeDetailRouteArgs {
  const RecipeDetailRouteArgs({
    this.key,
    required this.recipe,
  });

  final Key? key;

  final Recipe recipe;

  @override
  String toString() {
    return 'RecipeDetailRouteArgs{key: $key, recipe: $recipe}';
  }
}

/// generated route for
/// [GalleryPage]
class GalleryRoute extends PageRouteInfo<GalleryRouteArgs> {
  GalleryRoute({
    Key? key,
    required String recipeUuid,
    required String recipeName,
    List<PageRouteInfo>? children,
  }) : super(
          GalleryRoute.name,
          args: GalleryRouteArgs(
            key: key,
            recipeUuid: recipeUuid,
            recipeName: recipeName,
          ),
          rawPathParams: {'recipeUuid': recipeUuid},
          rawQueryParams: {'recipeName': recipeName},
          initialChildren: children,
        );

  static const String name = 'GalleryRoute';

  static const PageInfo<GalleryRouteArgs> page = PageInfo<GalleryRouteArgs>(name);
}

class GalleryRouteArgs {
  const GalleryRouteArgs({
    this.key,
    required this.recipeUuid,
    required this.recipeName,
  });

  final Key? key;

  final String recipeUuid;

  final String recipeName;

  @override
  String toString() {
    return 'GalleryRouteArgs{key: $key, recipeUuid: $recipeUuid, recipeName: $recipeName}';
  }
}
