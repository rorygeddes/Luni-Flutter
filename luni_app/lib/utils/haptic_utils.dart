import 'package:flutter/services.dart';

/// Haptic feedback utility for consistent tactile responses across the app
class HapticUtils {
  /// Light impact - For subtle interactions (e.g., selection changes, switches)
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact - For standard button presses
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact - For important actions (e.g., confirm, submit)
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click - For scrolling through lists or picker items
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate - For notifications or alerts
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  /// Success feedback - Combination for successful actions
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  /// Error feedback - For errors or failures
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
}

