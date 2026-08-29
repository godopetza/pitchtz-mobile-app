import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/status_views.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Bookings require player auth + booking creation, both `planned` on the
/// backend, so the tab shows a coming-soon state for now.
class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

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
              child: Text(loc.navBookings, style: AppText.h2),
            ),
          ),
          Expanded(
            child: StatusView(
              glyph: '🎟️',
              title: loc.bookingsSoonTitle,
              message: loc.bookingsSoonMessage,
            ),
          ),
        ],
      ),
    );
  }
}
