import 'package:flutter/material.dart';
import '../utils/haptic_utils.dart';

/// Custom button with automatic haptic feedback
/// Use this instead of regular buttons for consistent tactile feel
class LuniButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final bool isPrimary;
  final bool isDestructive;
  final Border? border;

  const LuniButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.width,
    this.height,
    this.isPrimary = true,
    this.isDestructive = false,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed == null
          ? null
          : () async {
              // Automatic haptic feedback based on button type
              if (isDestructive) {
                await HapticUtils.heavyImpact();
              } else if (isPrimary) {
                await HapticUtils.mediumImpact();
              } else {
                await HapticUtils.lightImpact();
              }
              onPressed?.call();
            },
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isPrimary
                  ? const Color(0xFFD4AF37)
                  : isDestructive
                      ? Colors.red
                      : Colors.grey.shade300),
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          border: border,
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: foregroundColor ??
                (isPrimary || isDestructive ? Colors.white : Colors.black87),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          child: child,
        ),
      ),
    );
  }
}

/// Custom GestureDetector with automatic haptic feedback
/// Drop-in replacement for GestureDetector
class LuniGestureDetector extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final HitTestBehavior? behavior;
  final bool enableHaptic;

  const LuniGestureDetector({
    super.key,
    required this.onTap,
    required this.child,
    this.behavior,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () async {
              if (enableHaptic) {
                await HapticUtils.mediumImpact();
              }
              onTap?.call();
            },
      behavior: behavior,
      child: child,
    );
  }
}

/// Custom IconButton with automatic haptic feedback
class LuniIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? color;
  final double? size;

  const LuniIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed == null
          ? null
          : () async {
              await HapticUtils.lightImpact();
              onPressed?.call();
            },
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}

/// Custom ElevatedButton with automatic haptic feedback
class LuniElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  const LuniElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed == null
          ? null
          : () async {
              await HapticUtils.mediumImpact();
              onPressed?.call();
            },
      style: style,
      child: child,
    );
  }
}

/// Custom TextButton with automatic haptic feedback
class LuniTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  const LuniTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed == null
          ? null
          : () async {
              await HapticUtils.lightImpact();
              onPressed?.call();
            },
      style: style,
      child: child,
    );
  }
}

/// Custom Switch with automatic haptic feedback
class LuniSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const LuniSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged == null
          ? null
          : (value) async {
              await HapticUtils.lightImpact();
              onChanged?.call(value);
            },
      activeColor: activeColor,
    );
  }
}

/// Custom Checkbox with automatic haptic feedback
class LuniCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Color? activeColor;

  const LuniCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged == null
          ? null
          : (value) async {
              await HapticUtils.lightImpact();
              onChanged?.call(value);
            },
      activeColor: activeColor,
    );
  }
}

/// Custom FilterChip with automatic haptic feedback
class LuniFilterChip extends StatelessWidget {
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final Widget label;
  final Color? selectedColor;

  const LuniFilterChip({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.label,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: onSelected == null
          ? null
          : (value) async {
              await HapticUtils.selectionClick();
              onSelected?.call(value);
            },
      label: label,
      selectedColor: selectedColor,
    );
  }
}

