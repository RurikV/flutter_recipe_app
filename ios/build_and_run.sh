#!/bin/bash

# This script builds the app, fixes the Flutter.framework nested framework issue,
# and then runs the app on the simulator

# Build the app for the simulator
echo "Building app for simulator..."
flutter build ios --simulator

# Check if the build was successful
if [ $? -ne 0 ]; then
  echo "Build failed. Exiting."
  exit 1
fi

# Run the fix_flutter_framework.sh script
echo "Fixing Flutter.framework nested framework issue..."
./ios/fix_flutter_framework.sh

# Check if the fix was successful
if [ $? -ne 0 ]; then
  echo "Fix failed. Exiting."
  exit 1
fi

# Install the app on the simulator using xcrun directly
echo "Installing app on simulator..."
SIMULATOR_ID="FAA92FB8-5FD0-4E6F-8AF9-40C13464CA93"  # iPhone 16 Plus
APP_PATH="build/ios/iphonesimulator/Runner.app"

xcrun simctl install $SIMULATOR_ID $APP_PATH

# Check if the installation was successful
if [ $? -ne 0 ]; then
  echo "Installation failed. Exiting."
  exit 1
fi

# Launch the app on the simulator
echo "Launching app on simulator..."
xcrun simctl launch $SIMULATOR_ID com.example.flutterRecipeApp

echo "Done."