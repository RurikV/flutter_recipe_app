import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:get_it/get_it.dart';
import 'theme/app_theme.dart';
import 'presentation/providers/language_provider.dart';
import 'l10n/app_localizations.dart';
import 'redux/app_state.dart';
import 'redux/store.dart';
import 'redux/actions.dart';
import 'services/auth/auth_service.dart';
import 'data/database/app_database.dart';
import 'services/classification/object_detection_service.dart';
import 'services/bluetooth_service.dart';
import 'domain/usecases/recipe_manager.dart';
import 'data/usecases/recipe_manager_impl.dart';
import 'domain/repositories/recipe_repository.dart';
import 'data/repositories/recipe_repository_impl.dart';
import 'domain/services/api_service.dart';
import 'data/services/api/api_service_impl.dart';
import 'domain/services/database_service.dart';
import 'data/services/database/database_service_impl.dart';
import 'domain/services/connectivity_service.dart';
import 'data/services/connectivity/connectivity_service_impl.dart';
import 'routing/app_router.dart';
// Use conditional imports for platform-specific implementations
import 'services/object_detection_service_locator.dart' as object_detection_locator;
import 'services/service_locator.dart' as service_locator;

// Global GetIt instance for dependency injection
final GetIt getIt = GetIt.instance;

void main() async {
  // Initialize Flutter binding before accessing platform services
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the service locator to register AppDatabase
  await service_locator.initLocator();

  // Initialize object detection service using the platform-specific implementation
  // This uses conditional imports to ensure only the appropriate implementation is included
  // The service is registered in the platform-specific implementation
  await object_detection_locator.initObjectDetectionService();

  // Initialize and register Bluetooth service only on mobile platforms
  if (defaultTargetPlatform == TargetPlatform.android || 
      defaultTargetPlatform == TargetPlatform.iOS) {
    final bluetoothService = BluetoothService();
    await bluetoothService.initialize();
    getIt.registerSingleton<BluetoothService>(bluetoothService);
  }

  // Register services as singletons
  getIt.registerSingleton<ApiService>(ApiServiceImpl());
  getIt.registerSingleton<DatabaseService>(DatabaseServiceImpl());
  getIt.registerSingleton<ConnectivityService>(ConnectivityServiceImpl());

  // Register RecipeRepository as a singleton with service dependencies
  getIt.registerSingleton<RecipeRepository>(
    RecipeRepositoryImpl(
      apiService: getIt<ApiService>(),
      databaseService: getIt<DatabaseService>(),
      connectivityService: getIt<ConnectivityService>()
    )
  );

  // Register RecipeManager as a singleton with RecipeRepository dependency
  getIt.registerSingleton<RecipeManager>(
    RecipeManagerImpl(recipeRepository: getIt<RecipeRepository>())
  );

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
        Provider<AppDatabase>(create: (context) => service_locator.get<AppDatabase>()),
        Provider<ObjectDetectionService>(create: (context) => getIt<ObjectDetectionService>()),
        // Only provide BluetoothService on mobile platforms
        if (defaultTargetPlatform == TargetPlatform.android || 
            defaultTargetPlatform == TargetPlatform.iOS)
          Provider<BluetoothService>(create: (context) => getIt<BluetoothService>()),
        Provider<ApiService>(create: (context) => getIt<ApiService>()),
        Provider<DatabaseService>(create: (context) => getIt<DatabaseService>()),
        Provider<ConnectivityService>(create: (context) => getIt<ConnectivityService>()),
        Provider<RecipeRepository>(create: (context) => getIt<RecipeRepository>()),
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
    final appRouter = AppRouter();

    return MaterialApp.router(
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

      // Navigator 2.0 configuration
      routerConfig: appRouter.config(),
    );
  }
}
