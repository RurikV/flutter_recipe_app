import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'presentation/providers/language_provider.dart';
import 'redux/app_state.dart';
import 'redux/store.dart';
import 'main.dart';

// This file is used for development purposes only
// It provides a simplified setup with minimal required providers
void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Create a basic Redux store for development
  final Store<AppState> store = createStore();

  // Run the app with minimal required providers
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
