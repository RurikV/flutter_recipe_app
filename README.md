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
- Flutter Version Manager (FVM) - recommended for consistent Flutter versions
- Android Studio or VS Code with Flutter extensions
- Android SDK for Android development
- Xcode for iOS development
- Git

## Getting Started

### Clone the Repository

```bash
git clone -b <latest-branch> https://github.com/RurikV/recipe_master
cd recipe_master
```

### Set Up Flutter Version Manager (FVM)

This project uses FVM to ensure all developers use the same Flutter version.

#### Option 1: Install FVM (Recommended)

1. **Install FVM:**
```bash
dart pub global activate fvm
```

2. **Add Dart global packages to your PATH** (if not already done):
   - **macOS/Linux:** Add this line to your `~/.bashrc`, `~/.zshrc`, or equivalent:
     ```bash
     export PATH="$PATH":"$HOME/.pub-cache/bin"
     ```
     Then restart your terminal or run `source ~/.zshrc` (or your shell config file).

   - **Windows:** Add `%USERPROFILE%\AppData\Local\Pub\Cache\bin` to your system PATH.

3. **Use the project's Flutter version:**
```bash
fvm use
```
This will automatically use the version specified in the `.fvmrc` file (3.7.2).

4. **Verify the installation:**
```bash
fvm flutter --version
```

#### Option 2: Use Regular Flutter (Alternative)

If you encounter issues with FVM installation or prefer to use your system Flutter:

1. **Ensure you have Flutter 3.7.2 installed:**
```bash
flutter --version
```

2. **If you need to switch Flutter versions, use Flutter's channel system:**
```bash
flutter channel stable
flutter upgrade
```

#### Troubleshooting FVM Installation

If you get `zsh: command not found: fvm` or similar errors:

1. **Check if Dart is installed:**
```bash
dart --version
```

2. **Reinstall FVM:**
```bash
dart pub global activate fvm
```

3. **Check if the pub cache bin directory is in your PATH:**
```bash
echo $PATH | grep pub-cache
```

4. **Manually add to PATH if needed:**
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### Install Dependencies

**With FVM:**
```bash
fvm flutter pub get
```

**Without FVM (using system Flutter):**
```bash
flutter pub get
```

### Generate Required Files

Some files need to be generated before running the app:

**With FVM:**
```bash
fvm flutter pub run build_runner build
```

**Without FVM (using system Flutter):**
```bash
flutter pub run build_runner build
```

## Running the App

The project has multiple entry points for different purposes:

### 1. Main Application (Production)

This is the standard entry point for the production version of the app:

**With FVM:**
```bash
fvm flutter run lib/main.dart
```

or simply:
```bash
fvm flutter run
```

**Without FVM (using system Flutter):**
```bash
flutter run lib/main.dart
```

or simply:
```bash
flutter run
```

### 2. Development Version

A simplified version for development and testing purposes. This version includes only the essential providers (LanguageProvider and Redux store) without the full service initialization, making it faster to start and easier to debug:

**With FVM:**
```bash
fvm flutter run lib/main_dev.dart
```

**Without FVM (using system Flutter):**
```bash
flutter run lib/main_dev.dart
```

**Benefits of main_dev.dart:**
- Faster startup time (no database, API, or Bluetooth service initialization)
- Minimal dependencies for quick testing
- Simplified provider setup for debugging UI components
- Ideal for UI development and testing without external services

### 3. Recipe Creation Test

A specialized entry point for testing recipe creation functionality:

**With FVM:**
```bash
fvm flutter run lib/test_recipe_creation.dart
```

**Without FVM (using system Flutter):**
```bash
flutter run lib/test_recipe_creation.dart
```

## Authentication

The app integrates with the FoodAPI service (https://foodapi.dzolotov.pro) for user authentication and recipe management. To use the app's features, you need to authenticate with valid credentials.

### Test User Credentials

For testing and development purposes, you can use the following test user credentials:

- **Username:** `user1`
- **Password:** `user1`

### How to Authenticate

#### 1. Using the App Interface

1. Launch the app using any of the entry points mentioned above
2. Navigate to the login/authentication screen
3. Enter the test credentials:
   - Username: `user1`
   - Password: `user1`
4. Tap the login button to authenticate

#### 2. API Authentication

The app uses the FoodAPI service for authentication. The authentication process works as follows:

1. **Login Endpoint:** `PUT https://foodapi.dzolotov.pro/user`
2. **Request Body:**
   ```json
   {
     "login": "user1",
     "password": "user1"
   }
   ```
3. **Response:** Returns a token and user ID for authenticated requests

#### 3. Direct User Profile Access

You can also access user profiles directly using the API:

```bash
curl https://foodapi.dzolotov.pro/user/1
```

This will return the user profile information for user ID 1 (which corresponds to the `user1` test account).

### Authentication Features

- **Automatic Token Management:** The app automatically handles authentication tokens
- **Persistent Login:** User sessions are maintained across app restarts
- **Fallback Authentication:** The app includes fallback mechanisms for API compatibility
- **User Profile Access:** Access to user-specific data like favorites and created recipes

### Troubleshooting Authentication

If you encounter authentication issues:

1. **Check Network Connection:** Ensure you have internet access to reach the FoodAPI service
2. **Verify Credentials:** Make sure you're using the correct test credentials (`user1`/`user1`)
3. **API Status:** The FoodAPI service should be accessible at https://foodapi.dzolotov.pro
4. **Clear App Data:** If persistent login issues occur, try clearing the app's stored data

For more detailed information about the API integration, see [FOODAPI_INTEGRATION.md](FOODAPI_INTEGRATION.md).

## Testing

### Run Unit Tests

**With FVM:**
```bash
fvm flutter test
```

**Without FVM (using system Flutter):**
```bash
flutter test
```

### Run Integration Tests

**With FVM:**
```bash
fvm flutter test integration_test
```

**Without FVM (using system Flutter):**
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
