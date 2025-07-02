// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Рецепты';

  @override
  String get recipes => 'Рецепты';

  @override
  String get favorites => 'Избранное';

  @override
  String get profile => 'Профиль';

  @override
  String get errorLoadingRecipes => 'Ошибка загрузки рецептов';

  @override
  String get noRecipesAvailable => 'Нет доступных рецептов';

  @override
  String get errorLoadingFavorites => 'Ошибка загрузки избранных рецептов';

  @override
  String get noFavoritesAvailable => 'Нет избранных рецептов';
}
