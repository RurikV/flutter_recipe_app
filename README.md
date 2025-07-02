# Flutter Recipe App

A Flutter application for managing and discovering recipes. This app allows users to browse recipes, add favorites, create new recipes, and more.

## Project Overview

The Flutter Recipe App is a comprehensive recipe management application with the following features:
- Browse and search recipes
- View detailed recipe information including ingredients and steps
- Add recipes to favorites
- Create and edit recipes
- Object detection for ingredients using TensorFlow Lite
- Bluetooth connectivity for external devices
- Multilingual support

## Prerequisites

- Flutter SDK (^3.7.2)
- Dart SDK (^3.7.2)
- Android Studio or VS Code with Flutter extensions
- Android SDK for Android development
- Xcode for iOS development
- Git

## Getting Started

### Clone the Repository

```bash
git clone -b <latest-branch> https://github.com/RurikV/flutter_recipe_app
cd flutter_recipe_app
```

### Install Dependencies

```bash
flutter pub get
```

### Generate Required Files

Some files need to be generated before running the app:

```bash
flutter pub run build_runner build
```

## Running the App

The project has multiple entry points for different purposes:

### 1. Main Application (Production)

This is the standard entry point for the production version of the app:

```bash
flutter run lib/main.dart
```

or simply:

```bash
flutter run
```

### 2. Development Version

A simplified version for development purposes:

```bash
flutter run lib/main_dev.dart
```

### 3. Recipe Creation Test

A specialized entry point for testing recipe creation functionality:

```bash
flutter run lib/test_recipe_creation.dart
```

## Testing

### Run Unit Tests

```bash
flutter test
```

### Run Integration Tests

```bash
flutter test integration_test
```

## Project Structure

- `lib/main.dart` - Main entry point for the application
- `lib/main_dev.dart` - Development entry point
- `lib/test_recipe_creation.dart` - Test entry point for recipe creation
- `lib/models/` - Data models
- `lib/screens/` - UI screens
- `lib/widgets/` - Reusable UI components
- `lib/services/` - Business logic and services
- `lib/database/` - Database related code
- `lib/redux/` - State management using Redux

## Additional Documentation

For information about the FoodAPI integration, see [FOODAPI_INTEGRATION.md](FOODAPI_INTEGRATION.md).
