import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../di/injection.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../bookings/view/bookings_page.dart';
import '../../explore/view/explore_page.dart';
import '../../explore/viewmodel/explore_viewmodel.dart';
import '../../favorites/view/favorites_page.dart';
import '../../fixtures/view/fixtures_page.dart';
import '../../fixtures/viewmodel/fixtures_viewmodel.dart';
import '../../profile/view/profile_page.dart';
import '../../profile/viewmodel/profile_viewmodel.dart';
import '../../shop/view/shop_page.dart';
import '../../shop/viewmodel/shop_viewmodel.dart';
import '../../teams/view/teams_page.dart';
import '../../watch_spots/view/watch_spots_page.dart';
import '../../watch_spots/viewmodel/watch_spots_viewmodel.dart';
import '../viewmodel/shell_viewmodel.dart';

/// The bottom-nav container hosting the primary tabs.
///
/// Tab order:
///   0  Explore      — live API (venues, availability, cities)
///   1  Bookings     — live API (GET /bookings)
///   2  Teams        — live API (/teams*)
///   3  Favorites    — in-memory (no backend fav-venues endpoint yet)
///   4  Fixtures     — live API (/fixtures*)
///   5  Shop         — live API (/shop/products, /shop/orders)
///   6  Watch Spots  — live API (/watch-spots)
///   7  Profile      — live API (/me)
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  // Text glyphs keep the nav bar dependency-free (no icon font required).
  static const _navIcons = ['◎', '▦', '⚑', '♥', '⚽', '▣', '📺', '◉'];

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
                // 0 — Explore
                ChangeNotifierProvider(
                  create: (_) => getIt<ExploreViewModel>()..load(),
                  child: const ExplorePage(),
                ),
                // 1 — Bookings
                const BookingsPage(),
                // 2 — Teams
                const TeamsPage(),
                // 3 — Favorites
                const FavoritesPage(),
                // 4 — Fixtures
                ChangeNotifierProvider(
                  create: (_) => getIt<FixturesViewModel>()..load(),
                  child: const FixturesPage(),
                ),
                // 5 — Shop
                ChangeNotifierProvider(
                  create: (_) => getIt<ShopViewModel>()..load(),
                  child: const ShopPage(),
                ),
                // 6 — Watch Spots
                ChangeNotifierProvider(
                  create: (_) => getIt<WatchSpotsViewModel>()..load(),
                  child: const WatchSpotsPage(),
                ),
                // 7 — Profile
                ChangeNotifierProvider(
                  create: (_) => getIt<ProfileViewModel>(),
                  child: const ProfilePage(),
                ),
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
      loc.navFixtures,
      loc.navShop,
      loc.navWatchSpots,
      loc.navProfile,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 26),
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
                          fontSize: 14,
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
                        fontSize: 9.5,
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
