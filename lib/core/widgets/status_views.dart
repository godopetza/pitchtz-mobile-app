import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'buttons.dart';

/// A centered loading spinner in brand green.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label});
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
                strokeWidth: 2.6, color: AppColors.primary),
          ),
          if (label != null) ...[
            const SizedBox(height: 14),
            Text(label!, style: AppText.small),
          ],
        ],
      ),
    );
  }
}

/// A generic empty / error / coming-soon state with an emoji glyph, copy and an
/// optional action button.
class StatusView extends StatelessWidget {
  const StatusView({
    super.key,
    required this.glyph,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final String glyph;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// A "planned feature" placeholder used across gated tabs.
  factory StatusView.comingSoon({
    String title = 'Coming soon',
    String message =
        'This is on the way. We’re building it right now — check back soon.',
    String glyph = '🚧',
  }) =>
      StatusView(glyph: glyph, title: title, message: message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: AppColors.neutralFill, shape: BoxShape.circle),
              child: Text(glyph, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13.5, height: 1.5, color: AppColors.muted)),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: 200,
                child: PrimaryButton(
                    label: actionLabel!, shadow: false, onTap: onAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
