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

/// Tab indices — stable across the IndexedStack.
class _Tab {
  static const int explore = 0;
  static const int bookings = 1;
  static const int teams = 2;
  static const int favorites = 3;
  static const int fixtures = 4;
  static const int shop = 5;
  static const int watchSpots = 6;
  static const int profile = 7;
}

/// Bottom-nav items (slim: Explore · Bookings · Profile).
const _bottomItems = [
  (icon: '◎', tab: _Tab.explore),
  (icon: '▦', tab: _Tab.bookings),
  (icon: '◉', tab: _Tab.profile),
];

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: getIt<ShellViewModel>(),
      child: Consumer<ShellViewModel>(
        builder: (context, shell, _) {
          return Scaffold(
            backgroundColor: AppColors.cream,
            drawer: _AppDrawer(shell: shell),
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

// ─── Navigation Drawer ────────────────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.shell});
  final ShellViewModel shell;

  void _go(BuildContext context, int tab) {
    Navigator.pop(context); // close drawer
    shell.setIndex(tab);
  }

  @override
  Widget build(BuildContext context) {
    final active = shell.index;

    return Drawer(
      width: 290,
      backgroundColor: AppColors.cream,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          _DrawerHeader(),
          // ── Nav items ───────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
              children: [
                _DrawerSection('MAIN'),
                _DrawerItem(
                  icon: '◎',
                  label: 'Explore',
                  active: active == _Tab.explore,
                  onTap: () => _go(context, _Tab.explore),
                ),
                _DrawerItem(
                  icon: '▦',
                  label: 'My Bookings',
                  active: active == _Tab.bookings,
                  onTap: () => _go(context, _Tab.bookings),
                ),
                const SizedBox(height: 8),
                _DrawerSection('DISCOVER'),
                _DrawerItem(
                  icon: '⚑',
                  label: 'Teams',
                  active: active == _Tab.teams,
                  onTap: () => _go(context, _Tab.teams),
                ),
                _DrawerItem(
                  icon: '♥',
                  label: 'Favorites',
                  active: active == _Tab.favorites,
                  onTap: () => _go(context, _Tab.favorites),
                ),
                _DrawerItem(
                  icon: '⚽',
                  label: 'Fixtures',
                  active: active == _Tab.fixtures,
                  onTap: () => _go(context, _Tab.fixtures),
                ),
                const SizedBox(height: 8),
                _DrawerSection('MORE'),
                _DrawerItem(
                  icon: '▣',
                  label: 'Shop',
                  active: active == _Tab.shop,
                  onTap: () => _go(context, _Tab.shop),
                ),
                _DrawerItem(
                  icon: '📺',
                  label: 'Watch Spots',
                  active: active == _Tab.watchSpots,
                  onTap: () => _go(context, _Tab.watchSpots),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Divider(color: AppColors.border, height: 1),
                ),
                _DrawerItem(
                  icon: '◉',
                  label: 'Profile',
                  active: active == _Tab.profile,
                  onTap: () => _go(context, _Tab.profile),
                ),
              ],
            ),
          ),
          // ── Footer ──────────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, 24 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.lime,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'PitchTZ v1.0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, 56 + MediaQuery.of(context).padding.top, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo mark
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '⚽',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'PitchTZ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // User avatar + info
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3), width: 2),
                ),
                child: const Text(
                  'JM',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'John Mwangi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.lime.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Member',
                        style: TextStyle(
                          color: AppColors.lime,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: AppColors.muted,
          ),
        ),
      );
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          active ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    icon,
                    style: TextStyle(
                      fontSize: 15,
                      color: active ? AppColors.lime : AppColors.muted,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight:
                        active ? FontWeight.w800 : FontWeight.w600,
                    color:
                        active ? AppColors.primary : AppColors.bodyText,
                  ),
                ),
                if (active) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Slim Bottom Nav (Explore · Bookings · Profile) ───────────────────────────

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
      loc.navProfile,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 26),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < _bottomItems.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(_bottomItems[i].tab),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: index == _bottomItems[i].tab
                            ? AppColors.primary.withValues(alpha: 0.10)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _bottomItems[i].icon,
                        style: TextStyle(
                          fontSize: 15,
                          color: index == _bottomItems[i].tab
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
                        fontWeight: index == _bottomItems[i].tab
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: index == _bottomItems[i].tab
                            ? AppColors.primary
                            : AppColors.faint,
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
