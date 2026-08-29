import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'tap_scale.dart';

/// The big dark-green pill CTA used to confirm/continue across the app.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.background = AppColors.primary,
    this.foreground = AppColors.cream,
    this.padding = 17,
    this.radius = AppSpacing.rLg,
    this.shadow = true,
    this.fontSize = 16,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final Color background;
  final Color foreground;
  final double padding;
  final double radius;
  final bool shadow;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: padding),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? background : AppColors.handle,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: shadow && enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppText.button.copyWith(
            color: enabled ? foreground : const Color(0xFF8A908C),
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}

/// White card-style button with a border (secondary action / social sign-in).
class OutlineButton extends StatelessWidget {
  const OutlineButton({
    super.key,
    required this.child,
    this.onTap,
    this.padding = 14,
    this.radius = AppSpacing.rLg,
    this.background = AppColors.white,
    this.border = AppColors.inputBorder,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double padding;
  final double radius;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: padding),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: border, width: 1.5),
        ),
        child: child,
      ),
    );
  }
}

/// A round icon button (back / share / favourite) with a translucent bg.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = 38,
    this.background = AppColors.white,
    this.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final Color background;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      scale: 0.9,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: border != null ? Border.all(color: border!) : null,
        ),
        child: child,
      ),
    );
  }
}
