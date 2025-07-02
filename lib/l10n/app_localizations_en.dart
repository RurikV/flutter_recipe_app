// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Recipes';

  @override
  String get recipes => 'Recipes';

  @override
  String get favorites => 'Favorites';

  @override
  String get profile => 'Profile';

  @override
  String get errorLoadingRecipes => 'Error loading recipes';

  @override
  String get noRecipesAvailable => 'No recipes available';

  @override
  String get errorLoadingFavorites => 'Error loading favorite recipes';

  @override
  String get noFavoritesAvailable => 'No favorite recipes';
}
