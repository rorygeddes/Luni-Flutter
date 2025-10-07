#!/bin/bash

# Luni Flutter App Runner
echo "🚀 Starting Luni Flutter App..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Check Flutter doctor
echo "🔍 Checking Flutter setup..."
flutter doctor

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Run the app
echo "🎨 Launching Luni App..."
flutter run

echo "✅ App launched successfully!"

