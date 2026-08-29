import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/status_views.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Favouriting a venue needs player auth (`/me/favorites` is `planned`), so the
/// tab is gated for now.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

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
              child: Text(loc.navFavorites, style: AppText.h2),
            ),
          ),
          Expanded(
            child: StatusView(
              glyph: '⭐',
              title: loc.favoritesSoonTitle,
              message: loc.favoritesSoonMessage,
            ),
          ),
        ],
      ),
    );
  }
}
