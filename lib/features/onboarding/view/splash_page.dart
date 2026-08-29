import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../di/injection.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../l10n/gen/app_localizations.dart';

/// The launch splash. After 1.8s it advances to Home when a session exists,
/// otherwise to onboarding (matching the design's `setTimeout(... 1800)`).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      final signedIn = getIt<AuthRepository>().isSignedIn;
      Navigator.pushReplacementNamed(
          context, signedIn ? Routes.home : Routes.onboarding);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.4, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (_, v, child) =>
                  Transform.scale(scale: v, child: Opacity(opacity: v.clamp(0, 1), child: child)),
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3.5),
                    ),
                    child: Center(
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Pitch TZ', style: AppText.splashTitle),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).tagline,
              style: AppText.body.copyWith(
                  color: AppColors.cream.withValues(alpha: 0.55)),
            ),
          ],
        ),
      ),
    );
  }
}
