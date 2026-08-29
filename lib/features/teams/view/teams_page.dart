import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/status_views.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Teams, leagues and challenges are `planned` backend features, so the tab is
/// gated for now.
class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      color: AppColors.cream,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 72, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(loc.navTeams, style: AppText.h2),
            ),
          ),
          Expanded(
            child: StatusView(
              glyph: '🏆',
              title: loc.teamsSoonTitle,
              message: loc.teamsSoonMessage,
            ),
          ),
        ],
      ),
    );
  }
}
