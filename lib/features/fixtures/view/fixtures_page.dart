import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/status_views.dart';
import '../../../domain/entities/fixture.dart';
import '../viewmodel/fixtures_viewmodel.dart';

class FixturesPage extends StatefulWidget {
  const FixturesPage({super.key});

  @override
  State<FixturesPage> createState() => _FixturesPageState();
}

class _FixturesPageState extends State<FixturesPage> {
  @override
  void initState() {
    super.initState();
    // Trigger initial load after frame so the widget tree is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FixturesViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FixturesViewModel>();

    return Container(
      color: AppColors.cream,
      child: Column(
        children: [
          _Header(vm: vm),
          Expanded(child: _Body(vm: vm)),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.vm});
  final FixturesViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cream,
      padding: const EdgeInsets.fromLTRB(20, AppSpacing.statusBar, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Fixtures', style: AppText.h2),
              ),
              // Live indicator badge
              if (vm.hasLive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDED),
                    borderRadius: BorderRadius.circular(AppSpacing.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE03535),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'LIVE',
                        style: AppText.overline.copyWith(
                          color: const Color(0xFFE03535),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _SportFilterRow(vm: vm),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _SportFilterRow extends StatelessWidget {
  const _SportFilterRow({required this.vm});
  final FixturesViewModel vm;

  @override
  Widget build(BuildContext context) {
    final chips = [
      ('All', 'all'),
      ('Football', 'football'),
      ('Basketball', 'basketball'),
    ];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final chip in chips)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: chip.$1,
                selected: vm.selectedSport == chip.$2,
                onTap: () => vm.setSport(chip.$2),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.pill),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.cream : AppColors.bodyText,
          ),
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.vm});
  final FixturesViewModel vm;

  @override
  Widget build(BuildContext context) {
    switch (vm.state) {
      case ViewState.loading:
        return const LoadingView(label: 'Loading fixtures…');
      case ViewState.error:
        return StatusView(
          glyph: '📡',
          title: 'Could not load fixtures',
          message: vm.error,
          actionLabel: 'Try again',
          onAction: vm.load,
        );
      case ViewState.ready:
        final hasAny = vm.liveFixtures.isNotEmpty ||
            vm.favoriteFixtures.isNotEmpty ||
            vm.upcomingFixtures.isNotEmpty ||
            vm.pastFixtures.isNotEmpty;

        if (!hasAny) {
          return StatusView(
            glyph: '📅',
            title: 'No fixtures today',
            message:
                'Check back later for live scores and upcoming matches.',
            actionLabel: 'Refresh',
            onAction: vm.load,
          );
        }
        return _FixtureList(vm: vm);
    }
  }
}

class _FixtureList extends StatelessWidget {
  const _FixtureList({required this.vm});
  final FixturesViewModel vm;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: vm.load,
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          if (vm.liveFixtures.isNotEmpty) ...[
            _SectionHeader(
              label: 'LIVE NOW',
              accent: const Color(0xFFE03535),
              dot: true,
            ),
            for (final f in vm.liveFixtures) _FixtureCard(fixture: f),
          ],
          if (vm.favoriteFixtures.isNotEmpty) ...[
            const _SectionHeader(label: 'FAVORITES'),
            for (final f in vm.favoriteFixtures) _FixtureCard(fixture: f),
          ],
          if (vm.pastFixtures.isNotEmpty) ...[
            const _SectionHeader(label: 'TODAY'),
            for (final f in vm.pastFixtures) _FixtureCard(fixture: f),
          ],
          if (vm.upcomingFixtures.isNotEmpty) ...[
            const _SectionHeader(label: 'UPCOMING'),
            for (final f in vm.upcomingFixtures) _FixtureCard(fixture: f),
          ],
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Data courtesy of LiveScore',
              style: AppText.tiny.copyWith(fontSize: 10.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    this.accent = AppColors.muted,
    this.dot = false,
  });

  final String label;
  final Color accent;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          if (dot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppText.overline.copyWith(color: accent, fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

// ─── Fixture Card ─────────────────────────────────────────────────────────────

class _FixtureCard extends StatelessWidget {
  const _FixtureCard({required this.fixture});
  final Fixture fixture;

  @override
  Widget build(BuildContext context) {
    final isLive = fixture.live;
    final hasScore = fixture.homeScore.isNotEmpty || fixture.awayScore.isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.rCard),
        border: Border.all(
          color: isLive
              ? const Color(0xFFE03535).withValues(alpha: 0.25)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // League row
          Row(
            children: [
              _LeagueBadge(
                sport: fixture.sport,
                league: fixture.league,
              ),
              const Spacer(),
              if (isLive)
                _LiveBadge(status: fixture.status)
              else
                _KickoffBadge(kickoffAt: fixture.kickoffAt, status: fixture.status),
            ],
          ),
          const SizedBox(height: 12),
          // Teams + score row
          Row(
            children: [
              Expanded(
                child: _TeamLabel(
                  name: fixture.home,
                  alignEnd: false,
                ),
              ),
              _ScoreBoard(
                homeScore: fixture.homeScore,
                awayScore: fixture.awayScore,
                hasScore: hasScore,
                isLive: isLive,
              ),
              Expanded(
                child: _TeamLabel(
                  name: fixture.away,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeagueBadge extends StatelessWidget {
  const _LeagueBadge({required this.sport, required this.league});
  final String sport;
  final String league;

  String get _sportEmoji {
    switch (sport.toLowerCase()) {
      case 'basketball':
        return '🏀';
      case 'tennis':
        return '🎾';
      default:
        return '⚽';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_sportEmoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 5),
        Text(
          league,
          style: AppText.tiny.copyWith(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDED),
        borderRadius: BorderRadius.circular(AppSpacing.pill),
      ),
      child: Text(
        status,
        style: AppText.tiny.copyWith(
          color: const Color(0xFFE03535),
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _KickoffBadge extends StatelessWidget {
  const _KickoffBadge({required this.kickoffAt, required this.status});
  final DateTime kickoffAt;
  final String status;

  String get _label {
    if (status == 'FT') return 'FT';
    if (status == 'HT') return 'HT';
    // Format kickoff time to +03:00 (EAT)
    final eat = kickoffAt.toUtc().add(const Duration(hours: 3));
    final h = eat.hour;
    final m = eat.minute;
    final ap = h >= 12 ? 'PM' : 'AM';
    final hh = h % 12 == 0 ? 12 : h % 12;
    final mm = m < 10 ? '0$m' : '$m';
    return '$hh:$mm $ap';
  }

  @override
  Widget build(BuildContext context) {
    final isFt = status == 'FT';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isFt ? AppColors.neutralFill : AppColors.cream,
        borderRadius: BorderRadius.circular(AppSpacing.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        _label,
        style: AppText.tiny.copyWith(
          color: isFt ? AppColors.bodyText : AppColors.muted,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _TeamLabel extends StatelessWidget {
  const _TeamLabel({required this.name, required this.alignEnd});
  final String name;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      textAlign: alignEnd ? TextAlign.right : TextAlign.left,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppText.label.copyWith(fontSize: 13.5, height: 1.3),
    );
  }
}

class _ScoreBoard extends StatelessWidget {
  const _ScoreBoard({
    required this.homeScore,
    required this.awayScore,
    required this.hasScore,
    required this.isLive,
  });

  final String homeScore;
  final String awayScore;
  final bool hasScore;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isLive
            ? AppColors.primary
            : hasScore
                ? AppColors.neutralFill
                : AppColors.cream,
        borderRadius: BorderRadius.circular(AppSpacing.rMd),
        border: isLive
            ? null
            : Border.all(color: AppColors.border),
      ),
      child: hasScore
          ? Text(
              '$homeScore – $awayScore',
              style: AppText.cardTitle.copyWith(
                color: isLive ? AppColors.lime : AppColors.ink,
                fontSize: 15,
                letterSpacing: 1,
              ),
            )
          : Text(
              'vs',
              style: AppText.tiny.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.faint,
              ),
            ),
    );
  }
}
