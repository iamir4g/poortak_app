#!/bin/bash

# Set up environment
export PATH="/Users/amir/development/flutter/bin:$PATH"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Navigate to project directory
cd /Users/amir/Documents/Project/poortak_app

echo "Building Flutter assets..."
flutter assemble --output=/Users/amir/Documents/Project/poortak_app/build/app/intermediates/flutter/release -dTargetFile=lib/main.dart -dTargetPlatform=android -dBuildMode=release -dTrackWidgetCreation=true -dTreeShakeIcons=true android_aot_bundle_release_android-arm android_aot_bundle_release_android-arm64 android_aot_bundle_release_android-x64

if [ $? -eq 0 ]; then
    echo "Flutter assets built successfully!"
    echo "Building APK with Gradle..."
    cd android
    ./gradlew assembleRelease
    if [ $? -eq 0 ]; then
        echo "APK built successfully!"
        echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
    else
        echo "Gradle build failed!"
        exit 1
    fi
else
    echo "Flutter assets build failed!"
    exit 1
fi







