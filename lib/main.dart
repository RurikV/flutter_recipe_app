import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:get_it/get_it.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'presentation/providers/language_provider.dart';
import 'l10n/app_localizations.dart';
import 'redux/app_state.dart';
import 'redux/store.dart';
import 'redux/actions.dart';
import 'services/auth_service.dart';
import 'database/app_database.dart';
import 'services/object_detection_service.dart';
import 'services/bluetooth_service.dart';
import 'domain/usecases/recipe_manager.dart';
// Use conditional imports for platform-specific implementations
import 'services/object_detection_service_locator.dart' as object_detection_locator;

// Global GetIt instance for dependency injection
final GetIt getIt = GetIt.instance;

void main() async {
  // Initialize Flutter binding before accessing platform services
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final AppDatabase appDatabase = AppDatabase();
  getIt.registerSingleton<AppDatabase>(appDatabase);

  // Initialize object detection service using the platform-specific implementation
  // This uses conditional imports to ensure only the appropriate implementation is included
  // The service is registered in the platform-specific implementation
  await object_detection_locator.initObjectDetectionService();

  // Initialize and register Bluetooth service
  final bluetoothService = BluetoothService();
  await bluetoothService.initialize();
  getIt.registerSingleton<BluetoothService>(bluetoothService);

  // Register RecipeManager as a singleton
  getIt.registerSingleton<RecipeManager>(RecipeManager());

  final Store<AppState> store = createStore();
  final authService = AuthService();

  // Check authentication status
  store.dispatch(CheckAuthStatusAction());

  // Load initial data
  store.dispatch(LoadRecipesAction());
  store.dispatch(LoadFavoriteRecipesAction());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        Provider<Store<AppState>>(create: (context) => store),
        Provider<AuthService>(create: (context) => authService),
        Provider<AppDatabase>(create: (context) => getIt<AppDatabase>()),
        Provider<ObjectDetectionService>(create: (context) => getIt<ObjectDetectionService>()),
        Provider<BluetoothService>(create: (context) => getIt<BluetoothService>()),
        Provider<RecipeManager>(create: (context) => getIt<RecipeManager>()),
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
      home: StoreConnector<AppState, bool>(
        converter: (store) => store.state.isAuthenticated,
        builder: (context, isAuthenticated) {
          return isAuthenticated ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
