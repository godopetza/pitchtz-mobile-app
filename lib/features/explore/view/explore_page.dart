import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/status_views.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../viewmodel/explore_viewmodel.dart';
import '../widgets/explore_sheets.dart';
import '../widgets/pitch_cards.dart';
import 'explore_map_view.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExploreViewModel>();
    if (vm.homeView == HomeView.map) {
      return Container(color: AppColors.cream, child: const ExploreMapView());
    }

    return Container(
      color: AppColors.cream,
      child: Column(
        children: [
          _header(context, vm),
          _searchRow(context, vm),
          Expanded(child: _body(context, vm)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, ExploreViewModel vm) {
    final loc = AppLocalizations.of(context);
    switch (vm.state) {
      case ViewState.loading:
        return LoadingView(label: loc.loadingPitches);
      case ViewState.error:
        return StatusView(
          glyph: '📡',
          title: loc.errLoadPitches,
          message: vm.error,
          actionLabel: loc.tryAgain,
          onAction: vm.load,
        );
      case ViewState.ready:
        if (vm.isEmpty) {
          return StatusView(
            glyph: '⚽',
            title: loc.emptyVenuesTitle,
            message: loc.emptyVenuesMessage(vm.cityName),
            actionLabel: loc.refresh,
            onAction: vm.load,
          );
        }
        return _content(context, vm);
    }
  }

  Widget _content(BuildContext context, ExploreViewModel vm) {
    final loc = AppLocalizations.of(context);
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: vm.load,
      child: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        children: [
          _mapPreview(context, vm),
          _aiCard(context, vm),
          _chips(context, vm),
          _sectionHeader(context, loc.availableNow,
              subtitle: loc.nPitchesIn(vm.available.length, vm.cityName),
              action: loc.seeAll),
          _featuredList(context, vm),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
            child: Text(loc.allVenues, style: AppText.sectionTitle),
          ),
          _venuesList(context, vm),
          if (vm.areas.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              child: Text(loc.exploreByArea, style: AppText.sectionTitle),
            ),
            _areaGrid(context, vm),
          ],
          _promoSection(context, vm),
        ],
      ),
    );
  }

  // ---- Header ----
  Widget _header(BuildContext context, ExploreViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 62, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).greeting,
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500)),
                GestureDetector(
                  onTap: () => showCitySheet(context, vm),
                  child: Row(
                    children: [
                      Flexible(child: Text(vm.cityName, style: AppText.h3)),
                      const SizedBox(width: 6),
                      const Text('▼',
                          style:
                              TextStyle(fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.menu_rounded,
                  size: 20, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchRow(BuildContext context, ExploreViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, Routes.results),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 16, color: AppColors.muted),
                    const SizedBox(width: 10),
                    Text(AppLocalizations.of(context).searchHint,
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.faint,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => showFilterSheet(context, vm),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_tuneBar(18), const SizedBox(height: 4), _tuneBar(12), const SizedBox(height: 4), _tuneBar(6)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tuneBar(double w) => Container(
      width: w,
      height: 2,
      decoration: BoxDecoration(
          color: AppColors.lime, borderRadius: BorderRadius.circular(1)));

  Widget _mapPreview(BuildContext context, ExploreViewModel vm) {
    return GestureDetector(
      onTap: vm.showMap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        height: 74,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: AppColors.mapBg)),
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(AppLocalizations.of(context).mapViewCta,
                      style: TextStyle(
                          color: AppColors.cream,
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ),
            const Positioned(left: 24, top: 22, child: Icon(Icons.place, color: AppColors.primary, size: 22)),
            const Positioned(left: 120, top: 34, child: Icon(Icons.place, color: AppColors.primary, size: 18)),
          ],
        ),
      ),
    );
  }

  Widget _aiCard(BuildContext context, ExploreViewModel vm) {
    final loc = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, Routes.ai),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryGradientEnd],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(8)),
              child: Text('✦',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.primary)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(loc.askPitchAi,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cream)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.lime.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(loc.soonBadge,
                            style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.lime)),
                      ),
                    ],
                  ),
                  Text(loc.aiExample,
                      style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.cream.withValues(alpha: 0.55))),
                ],
              ),
            ),
            const Text('›', style: TextStyle(color: AppColors.lime, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _chips(BuildContext context, ExploreViewModel vm) {
    final loc = AppLocalizations.of(context);
    final labels = [
      loc.chipTonight,
      loc.chipTomorrow,
      loc.chipWeekend,
      loc.chipNearMe,
      '5-a-side',
      '7-a-side',
      '11-a-side',
    ];
    // Tall enough for the pill (2×9px padding + text line) plus the list's own
    // vertical padding — and each chip is wrapped in Center so it keeps its
    // natural height instead of being stretched/clipped by the horizontal
    // ListView's tight cross-axis constraints.
    return SizedBox(
      height: 66,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        children: [
          for (int i = 0; i < labels.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: GestureDetector(
                  onTap: () => vm.toggleChip(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                    decoration: BoxDecoration(
                      color:
                          vm.isChipOn(i) ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                          color: vm.isChipOn(i)
                              ? AppColors.primary
                              : AppColors.border),
                    ),
                    child: Text(labels[i],
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: vm.isChipOn(i)
                                ? AppColors.cream
                                : AppColors.bodyText)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title,
      {String? subtitle, String? action}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.sectionTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.small),
                ],
              ],
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, Routes.results),
              child: Text(action,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _featuredList(BuildContext context, ExploreViewModel vm) {
    return SizedBox(
      height: 262,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: vm.available.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final p = vm.available[i];
          return TonightCard(
            pitch: p,
            onTap: () =>
                Navigator.pushNamed(context, Routes.detail, arguments: p.id),
            onToggleFav: () => vm.showComingSoon(
                AppLocalizations.of(context).favoritesComingSoonToast),
          );
        },
      ),
    );
  }

  Widget _venuesList(BuildContext context, ExploreViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (final p in vm.allVenues) ...[
            PitchListRow(
              pitch: p,
              onTap: () =>
                  Navigator.pushNamed(context, Routes.detail, arguments: p.id),
              onToggleFav: () => vm.showComingSoon(
                  AppLocalizations.of(context).favoritesComingSoonToast),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _areaGrid(BuildContext context, ExploreViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
        children: [
          for (final a in vm.areas)
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, Routes.results),
              child: Container(
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -32,
                      top: -16,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.lime.withValues(alpha: 0.14),
                              width: 10),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(a.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 15,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                                color: AppColors.cream)),
                        const SizedBox(height: 2),
                        Text(AppLocalizations.of(context).nPitches(a.count),
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 11.5,
                                height: 1.2,
                                color:
                                    AppColors.cream.withValues(alpha: 0.55))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _promoSection(BuildContext context, ExploreViewModel vm) {
    final loc = AppLocalizations.of(context);
    Widget promo(String eyebrow, Color color, String title, String body,
        {bool dark = false}) {
      return GestureDetector(
        onTap: () => vm.showComingSoon(loc.promoComingSoonToast),
        child: Container(
          width: 210,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dark ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: dark ? null : Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: color)),
              const SizedBox(height: 6),
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: dark ? AppColors.cream : AppColors.ink)),
              const SizedBox(height: 4),
              Text(body,
                  style: TextStyle(
                      fontSize: 11.5,
                      height: 1.5,
                      color: dark
                          ? AppColors.cream.withValues(alpha: 0.6)
                          : AppColors.muted)),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                    color: dark ? AppColors.lime : AppColors.primary,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(loc.comingSoon,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color:
                            dark ? AppColors.primaryDark : AppColors.cream)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          child: Text(loc.moreThanPitch, style: AppText.sectionTitle),
        ),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              promo('IN VENUE', AppColors.lime, 'PS5 lounge',
                  'FC 26 before or after your game',
                  dark: true),
              const SizedBox(width: 12),
              promo('ONLINE', AppColors.orange, 'FC 26 tournament',
                  'Weekly bracket · TSh 5K entry'),
              const SizedBox(width: 12),
              promo('FANTASY', AppColors.fantasyBlue, 'FPL league',
                  'Compete with your crew · free'),
            ],
          ),
        ),
      ],
    );
  }
}
