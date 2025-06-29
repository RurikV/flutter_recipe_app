#!/bin/bash

# This script fixes the Flutter.framework nested framework issue
# Run this script after building the app and before running it on the simulator

# Find the build directory
BUILD_DIR="build/ios/iphonesimulator"

# Check if the build directory exists
if [ ! -d "$BUILD_DIR" ]; then
  echo "Build directory not found: $BUILD_DIR"
  exit 1
fi

# Find the app bundle
APP_BUNDLE=$(find "$BUILD_DIR" -name "*.app" -type d | head -n 1)

if [ -z "$APP_BUNDLE" ]; then
  echo "App bundle not found in $BUILD_DIR"
  exit 1
fi

echo "Found app bundle: $APP_BUNDLE"

# Find the Flutter.framework directory
FLUTTER_FRAMEWORK=$(find "$APP_BUNDLE" -name "Flutter.framework" -type d | head -n 1)

if [ -z "$FLUTTER_FRAMEWORK" ]; then
  echo "Flutter.framework not found in $APP_BUNDLE"
  exit 1
fi

echo "Found Flutter.framework: $FLUTTER_FRAMEWORK"

# Find any nested Flutter.framework directories
NESTED_FRAMEWORKS=$(find "$FLUTTER_FRAMEWORK" -name "Flutter.framework" -type d)

if [ -z "$NESTED_FRAMEWORKS" ]; then
  echo "No nested Flutter.framework found. Nothing to fix."
  exit 0
fi

# Remove the nested Flutter.framework directories
for NESTED_FRAMEWORK in $NESTED_FRAMEWORKS; do
  echo "Removing nested framework: $NESTED_FRAMEWORK"
  rm -rf "$NESTED_FRAMEWORK"
done

echo "Fixed Flutter.framework nested framework issue."