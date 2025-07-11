import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:recipe_master/presentation/providers/language_provider.dart';
import 'package:recipe_master/main.dart';
import 'package:recipe_master/redux/app_state.dart';
import 'package:recipe_master/redux/store.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

void main() {
  group('Main Dev Setup Tests', () {
    testWidgets('LanguageProvider should be accessible in main_dev setup', (WidgetTester tester) async {
      // Create the same setup as main_dev.dart
      final Store<AppState> store = createStore();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => LanguageProvider()),
            Provider<Store<AppState>>(create: (context) => store),
          ],
          child: StoreProvider<AppState>(
            store: store,
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  // This should not throw an error if LanguageProvider is properly set up
                  final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
                  
                  return Scaffold(
                    body: Center(
                      child: Text('Language: ${languageProvider.locale.languageCode}'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Verify that the widget builds without errors
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.textContaining('Language:'), findsOneWidget);
      
      print('[DEBUG_LOG] LanguageProvider is accessible in main_dev setup');
    });

    testWidgets('MyApp widget should work with main_dev providers', (WidgetTester tester) async {
      // Create the same setup as main_dev.dart
      final Store<AppState> store = createStore();

      await tester.pumpWidget(
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

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that MyApp builds without the LanguageProvider error
      expect(find.byType(MyApp), findsOneWidget);
      
      print('[DEBUG_LOG] MyApp works correctly with main_dev provider setup');
    });
  });
}