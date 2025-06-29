import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'presentation/providers/language_provider.dart';
import 'l10n/app_localizations.dart';
import 'redux/app_state.dart';
import 'redux/store.dart';
import 'redux/actions.dart';

void main() {
  final Store<AppState> store = createStore();

  // Load initial data
  store.dispatch(LoadRecipesAction());
  store.dispatch(LoadFavoriteRecipesAction());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        Provider<Store<AppState>>(create: (context) => store),
      ],
      child: StoreProvider<AppState>(
        store: store,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'Recipes',
      debugShowCheckedModeBanner: false,

      // Localization setup
      locale: languageProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      theme: ThemeData(
        // Use AppTheme's base theme
        colorScheme: AppTheme.theme.colorScheme,
        textTheme: AppTheme.theme.textTheme,
        // Add custom page transitions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            // Use FadeUpwardsPageTransitionsBuilder for all platforms
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
