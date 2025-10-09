# Haptic Feedback Guide

## Overview

Haptic feedback provides tactile responses when users interact with the app, making it feel more responsive and premium (like World App, ChatGPT, etc.).

## Setup

The `HapticUtils` class (`lib/utils/haptic_utils.dart`) provides consistent haptic feedback across the app.

## Usage

### Import
```dart
import '../utils/haptic_utils.dart';
```

### Available Feedback Types

#### 1. **Light Impact** - Subtle interactions
Use for: Selection changes, switches, toggles
```dart
await HapticUtils.lightImpact();
```

#### 2. **Medium Impact** - Standard button presses
Use for: Most buttons, navigation
```dart
await HapticUtils.mediumImpact();
```

#### 3. **Heavy Impact** - Important actions
Use for: Confirm, submit, delete actions
```dart
await HapticUtils.heavyImpact();
```

#### 4. **Selection Click** - Scrolling/picker
Use for: Scrolling through lists, picker items
```dart
await HapticUtils.selectionClick();
```

#### 5. **Success** - Success feedback
Use for: Successful operations
```dart
await HapticUtils.success();
```

#### 6. **Error** - Error feedback
Use for: Failed operations, errors
```dart
await HapticUtils.error();
```

## Examples

### Button with Haptic Feedback
```dart
GestureDetector(
  onTap: () async {
    await HapticUtils.mediumImpact(); // Immediate feedback
    
    final success = await someAsyncOperation();
    
    if (success) {
      await HapticUtils.success(); // Success pattern
    } else {
      await HapticUtils.error(); // Error pattern
    }
  },
  child: Text('Tap Me'),
)
```

### Submit Button
```dart
ElevatedButton(
  onPressed: () async {
    await HapticUtils.heavyImpact(); // Important action
    await submitForm();
  },
  child: Text('Submit'),
)
```

### Toggle Switch
```dart
Switch(
  value: isEnabled,
  onChanged: (value) async {
    await HapticUtils.lightImpact(); // Subtle feedback
    setState(() => isEnabled = value);
  },
)
```

### Accept/Reject Actions
```dart
// Accept
GestureDetector(
  onTap: () async {
    await HapticUtils.mediumImpact();
    final success = await acceptRequest();
    if (success) await HapticUtils.success();
  },
  child: Text('Accept'),
)

// Reject
GestureDetector(
  onTap: () async {
    await HapticUtils.lightImpact(); // Lighter for reject
    await rejectRequest();
  },
  child: Text('Reject'),
)
```

## Guidelines

1. **Don't Overuse**: Only add haptic feedback to intentional user actions
2. **Match Intensity**: Light for subtle, Medium for standard, Heavy for important
3. **Success/Error Patterns**: Use the built-in success/error methods for consistent feel
4. **Performance**: Haptic calls are async but fast, no need to await in most cases

## Where It's Applied

Currently implemented in:
- ✅ Social Screen
  - Accept friend request (medium + success)
  - Reject friend request (light)
  - Add friend button (medium + success/error)
  - Message button (light)

To add to other screens, follow the same pattern!

