import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/status_views.dart';
import '../../../l10n/gen/app_localizations.dart';

/// "Pitch AI" is a `planned` backend feature (no endpoint yet), so the screen
/// shows a coming-soon state.
class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Padding(
        padding: const EdgeInsets.only(top: 62),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: Row(
                children: [
                  CircleIconButton(
                    border: AppColors.border,
                    onTap: () => Navigator.pop(context),
                    child: const Text('‹', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text('✦',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppColors.primary)),
                  ),
                  const SizedBox(width: 8),
                  Text('Pitch AI', style: AppText.title.copyWith(fontSize: 18)),
                ],
              ),
            ),
            Expanded(
              child: StatusView(
                glyph: '🤖',
                title: AppLocalizations.of(context).aiSoonTitle,
                message: AppLocalizations.of(context).aiSoonMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
