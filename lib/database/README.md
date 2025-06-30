# Cross-Platform Database Implementation

This directory contains a cross-platform database implementation for the Flutter Recipe App. The implementation uses [drift](https://pub.dev/packages/drift) (formerly moor) for database access and [get_it](https://pub.dev/packages/get_it) for dependency injection.

## How It Works

The implementation uses conditional imports and a service locator pattern to provide different database implementations for different platforms:

- For web platforms, it uses `WebDatabase` from drift/web.dart
- For native platforms (Android, iOS, desktop), it uses `NativeDatabase` from drift/native.dart

The service locator pattern ensures that the correct implementation is used at runtime based on the platform.

## Key Components

### 1. Service Locator

The service locator pattern is implemented using the following files:

- `lib/service_locator.dart`: Exports the appropriate implementation based on the platform
- `lib/service_locator_native.dart`: Implementation for native platforms
- `lib/service_locator_web.dart`: Implementation for web platforms
- `lib/unsupported.dart`: Fallback implementation for unsupported platforms

### 2. Database Connection

The database connection is handled by:

- `lib/database/database_connection.dart`: Provides a platform-agnostic way to open a database connection

### 3. Database Implementation

The database implementation is in:

- `lib/database/app_database.dart`: The main database class that uses the service locator

## Usage

### Initialization

Initialize the database in your `main.dart` file:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.initialize();
  runApp(MyApp());
}
```

### Getting the Database Instance

Get the database instance using the service locator:

```dart
final database = AppDatabase.getInstance();
```

### Using the Database

Use the database instance to perform operations:

```dart
// Get all recipes
final recipes = await database.getAllRecipes();

// Add a recipe to favorites
await database.addToFavorites(recipeUuid);

// Remove a recipe from favorites
await database.removeFromFavorites(recipeUuid);
```

## Example

See `lib/examples/database_usage_example.dart` for a complete example of how to use the cross-platform database implementation.

## Dependencies

The implementation requires the following dependencies:

```yaml
dependencies:
  drift: ^2.15.0
  sqlite3_flutter_libs: ^0.5.20
  path_provider: ^2.1.2
  path: ^1.8.3
  sqlite3: ^2.1.0
  web: ^0.5.0
  get_it: ^7.6.7
  ffi: any
```

## Platform Support

This implementation supports the following platforms:

- Android
- iOS
- Web
- macOS
- Windows
- Linux

## Troubleshooting

If you encounter issues with the database implementation, check the following:

1. Make sure you have initialized the database using `AppDatabase.initialize()`
2. Make sure you have the correct dependencies in your `pubspec.yaml`
3. Make sure you are using the correct import paths