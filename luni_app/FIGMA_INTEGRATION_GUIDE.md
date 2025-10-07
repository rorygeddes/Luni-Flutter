# Figma to Flutter Integration Guide

## 🎨 Getting Started with Your Figma Design

This guide will help you transform your Figma design into a fully functional Flutter app.

## 📁 Project Structure

Your Flutter project is organized as follows:

```
lib/
├── main.dart                 # App entry point
├── screens/                  # All your app screens
│   └── home_screen.dart     # Example home screen
├── widgets/                  # Reusable UI components
├── providers/                # State management
│   └── app_provider.dart    # App-wide state
├── theme/                    # App theming
│   └── app_theme.dart       # Colors, typography, etc.
├── models/                   # Data models
├── services/                 # API calls, data services
└── utils/                    # Helper functions

assets/
├── images/                   # PNG, JPG images from Figma
├── icons/                    # SVG icons from Figma
└── fonts/                    # Custom fonts from Figma
```

## 🚀 Step-by-Step Integration Process

### 1. Export Assets from Figma

#### Images:
- Select your images in Figma
- Right-click → "Export"
- Choose PNG or JPG format
- Use 2x or 3x resolution for better quality
- Save to `assets/images/`

#### Icons:
- Select icons in Figma
- Right-click → "Export"
- Choose SVG format (preferred for scalability)
- Save to `assets/icons/`

#### Fonts:
- In Figma, go to the font dropdown
- Click "Manage fonts" or download the font file
- Save font files (.ttf, .otf) to `assets/fonts/`

### 2. Update pubspec.yaml for Assets

Add your fonts to `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: YourCustomFont
      fonts:
        - asset: assets/fonts/YourCustomFont-Regular.ttf
        - asset: assets/fonts/YourCustomFont-Bold.ttf
          weight: 700
```

### 3. Update Theme Colors

Edit `lib/theme/app_theme.dart` to match your Figma design:

```dart
class AppTheme {
  // Replace these with your Figma colors
  static const Color primaryColor = Color(0xFF6366F1); // Your primary color
  static const Color secondaryColor = Color(0xFF8B5CF6); // Your secondary color
  static const Color accentColor = Color(0xFF06B6D4); // Your accent color
  // ... add more colors as needed
}
```

### 4. Create Screens from Figma

For each screen in your Figma design:

1. Create a new file in `lib/screens/` (e.g., `login_screen.dart`)
2. Use the existing `home_screen.dart` as a template
3. Build your UI using Flutter widgets

Example screen structure:
```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.w), // Using ScreenUtil for responsive design
        child: Column(
          children: [
            // Your UI components here
          ],
        ),
      ),
    );
  }
}
```

### 5. Create Reusable Widgets

For components that appear multiple times:

1. Create files in `lib/widgets/` (e.g., `custom_button.dart`)
2. Make them reusable with parameters

Example custom widget:
```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      ),
      child: Text(text),
    );
  }
}
```

## 🛠️ Useful Flutter Widgets for Figma Designs

### Layout Widgets:
- `Container` - For backgrounds, padding, margins
- `Column` - Vertical layouts
- `Row` - Horizontal layouts
- `Stack` - Overlapping elements
- `Expanded` - Flexible sizing
- `SizedBox` - Fixed spacing

### UI Components:
- `Text` - Typography
- `Image` - Images and icons
- `ElevatedButton` - Primary buttons
- `OutlinedButton` - Secondary buttons
- `TextField` - Input fields
- `Card` - Card layouts
- `AppBar` - Top navigation

### Responsive Design:
- Use `ScreenUtil` for responsive sizing:
  ```dart
  width: 100.w    // Responsive width
  height: 50.h    // Responsive height
  fontSize: 16.sp // Responsive font size
  ```

## 🎯 Best Practices

### 1. Naming Conventions:
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables: `camelCase`
- Constants: `UPPER_SNAKE_CASE`

### 2. Code Organization:
- Keep screens simple and focused
- Extract complex UI into separate widgets
- Use providers for state management
- Follow the existing folder structure

### 3. Performance:
- Use `const` constructors when possible
- Implement proper image caching
- Use `ListView.builder` for long lists

## 🔧 Running Your App

1. **Install Flutter** (if not already installed):
   ```bash
   # Check if Flutter is installed
   flutter doctor
   ```

2. **Run the app**:
   ```bash
   cd luni_app
   flutter run
   ```

3. **Hot Reload**: Save your changes and press `r` in the terminal for instant updates

## 📱 Testing on Different Devices

- **iOS Simulator**: `flutter run -d ios`
- **Android Emulator**: `flutter run -d android`
- **Web**: `flutter run -d web`
- **Desktop**: `flutter run -d macos` (or windows/linux)

## 🎨 Design System Tips

1. **Consistent Spacing**: Use multiples of 8 (8, 16, 24, 32, etc.)
2. **Typography Scale**: Define consistent text styles in your theme
3. **Color Palette**: Use semantic color names (primary, secondary, error, etc.)
4. **Component Library**: Build reusable components for common patterns

## 🚀 Next Steps

1. Start with your main screen
2. Export and add your assets
3. Update the theme colors
4. Build screen by screen
5. Test on different devices
6. Refine and polish

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Material Design Guidelines](https://material.io/design)
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
- [Responsive Design with ScreenUtil](https://pub.dev/packages/flutter_screenutil)

Happy coding! 🎉

