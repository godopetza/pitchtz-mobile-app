import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../di/injection.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../bookings/view/bookings_page.dart';
import '../../explore/view/explore_page.dart';
import '../../explore/viewmodel/explore_viewmodel.dart';
import '../../favorites/view/favorites_page.dart';
import '../../profile/view/profile_page.dart';
import '../../profile/viewmodel/profile_viewmodel.dart';
import '../../teams/view/teams_page.dart';
import '../viewmodel/shell_viewmodel.dart';

/// The bottom-nav container hosting the five primary tabs. Only Explore is
/// backed by the live API today; Bookings, Teams and Favorites show
/// coming-soon states until their backend features ship.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _navIcons = ['◎', '▦', '⚑', '♥', '◉'];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: getIt<ShellViewModel>(),
      child: Consumer<ShellViewModel>(
        builder: (context, shell, _) {
          return Scaffold(
            backgroundColor: AppColors.cream,
            body: IndexedStack(
              index: shell.index,
              children: [
                ChangeNotifierProvider(
                    create: (_) => getIt<ExploreViewModel>()..load(),
                    child: const ExplorePage()),
                const BookingsPage(),
                const TeamsPage(),
                const FavoritesPage(),
                ChangeNotifierProvider(
                    create: (_) => getIt<ProfileViewModel>(),
                    child: const ProfilePage()),
              ],
            ),
            bottomNavigationBar: _BottomNav(
              index: shell.index,
              onTap: shell.setIndex,
            ),
          );
        },
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final labels = [
      loc.navExplore,
      loc.navBookings,
      loc.navTeams,
      loc.navFavorites,
      loc.navProfile,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 26),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.94),
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == index
                            ? AppColors.navActiveBg
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        MainShell._navIcons[i],
                        style: TextStyle(
                          fontSize: 15,
                          color: i == index
                              ? AppColors.primary
                              : AppColors.faint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight:
                            i == index ? FontWeight.w800 : FontWeight.w600,
                        color:
                            i == index ? AppColors.primary : AppColors.faint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
