import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/status_views.dart';
import '../../../core/widgets/tap_scale.dart';
import '../../../core/widgets/turf_image.dart';
import '../../../domain/entities/review.dart';
import '../../../domain/entities/time_slot.dart';
import '../../../domain/entities/venue_extra.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../viewmodel/detail_viewmodel.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailViewModel>();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: switch (vm.state) {
        DetailState.loading => SafeArea(
            child: LoadingView(label: AppLocalizations.of(context).loadingVenue)),
        DetailState.error => SafeArea(
            child: Stack(
              children: [
                StatusView(
                  glyph: '📡',
                  title: AppLocalizations.of(context).errLoadVenue,
                  message: vm.error,
                ),
                Positioned(
                  top: 12,
                  left: 16,
                  child: CircleIconButton(
                    border: AppColors.border,
                    onTap: () => Navigator.pop(context),
                    child: const Text('‹', style: TextStyle(fontSize: 17)),
                  ),
                ),
              ],
            ),
          ),
        DetailState.ready => _content(context, vm),
      },
    );
  }

  Widget _content(BuildContext context, DetailViewModel vm) {
    final pitch = vm.pitch;
    final loc = AppLocalizations.of(context);

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            // ---- Hero ----
            SizedBox(
              height: 300,
              child: TurfImage(
                imageUrl: pitch.imageUrl,
                gradient1: Color(pitch.gradient1),
                gradient2: Color(pitch.gradient2),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF0A1E16).withValues(alpha: 0.35),
                              Colors.transparent,
                              const Color(0xFF0A1E16).withValues(alpha: 0.3),
                            ],
                            stops: const [0, 0.4, 1],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 58,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleIconButton(
                            background:
                                AppColors.cream.withValues(alpha: 0.94),
                            onTap: () => Navigator.pop(context),
                            child:
                                const Text('‹', style: TextStyle(fontSize: 17)),
                          ),
                          CircleIconButton(
                            background:
                                AppColors.cream.withValues(alpha: 0.94),
                            onTap: () => vm.showComingSoon(
                                AppLocalizations.of(context)
                                    .favoritesComingSoonToast),
                            child: const Text('♡',
                                style: TextStyle(
                                    fontSize: 16, color: AppColors.ink)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ---- Body ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pitch.name, style: AppText.h2),
                            const SizedBox(height: 3),
                            Text(
                                '★ ${pitch.rating > 0 ? pitch.rating.toStringAsFixed(1) : loc.ratingNew}'
                                '${vm.reviews.isNotEmpty ? ' · ${loc.nReviews(vm.reviews.length)}' : ''}'
                                '${pitch.area.isNotEmpty ? ' · ${pitch.area}' : ''}',
                                style: TextStyle(
                                    fontSize: 13, color: AppColors.muted)),
                          ],
                        ),
                      ),
                      if (pitch.verified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(loc.verifiedBadge,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.successText)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      for (int i = 0; i < vm.quickInfo.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(child: _quickTile(vm.quickInfo[i])),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),
                  _priceCard(context, vm),
                  _SectionTitle(loc.chooseDate),
                  _dateRow(vm),
                  _SectionTitle(loc.checkAvailability),
                  ...vm.slotGroups.map((g) => _slotGroup(context, vm, g)),
                  const SizedBox(height: 14),
                  _durationBanner(context, vm),
                  if (vm.amenities.isNotEmpty) ...[
                    _SectionTitle(loc.amenities),
                    _amenities(vm.amenities),
                  ],
                  if (vm.goodToKnow.isNotEmpty) ...[
                    _SectionTitle(loc.goodToKnow),
                    _goodToKnow(vm.goodToKnow),
                  ],
                  if (vm.details.extras.isNotEmpty) ...[
                    _SectionTitle(loc.availableExtras),
                    _extras(context, vm.details.extras),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(loc.reviews,
                          style: AppText.title.copyWith(fontSize: 17)),
                      if (vm.reviews.isNotEmpty)
                        Text(
                            '★ ${pitch.rating > 0 ? pitch.rating.toStringAsFixed(1) : loc.ratingNew} · ${vm.reviews.length}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (vm.reviewTags.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [for (final t in vm.reviewTags) _reviewTag(t)],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (vm.reviews.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Text(loc.noReviewsYet, style: AppText.bodyMuted),
                    )
                  else
                    for (final r in vm.reviews) _reviewCard(context, r),
                  const SizedBox(height: 20),
                  _confirmBanner(context),
                ],
              ),
            ),
          ],
        ),
        // ---- Sticky CTA (booking is a planned backend feature) ----
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.cream.withValues(alpha: 0),
                  AppColors.cream,
                ],
                stops: const [0, 0.3],
              ),
            ),
            child: PrimaryButton(
              label: vm.hasSelection
                  ? AppLocalizations.of(context)
                      .bookingComingSoonPrice(Formatters.tsh(vm.pitchFee))
                  : AppLocalizations.of(context).bookingComingSoon,
              onTap: () => vm.showComingSoon(
                  AppLocalizations.of(context).bookingComingSoonToast),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickTile(QuickInfo q) => Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Text(q.big,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(q.small, style: AppText.tiny.copyWith(fontSize: 10.5)),
          ],
        ),
      );

  Widget _priceCard(BuildContext context, DetailViewModel vm) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink),
                      children: [
                        TextSpan(text: Formatters.tsh(vm.pitch.pricePerHour)),
                        TextSpan(
                            text: AppLocalizations.of(context).perHour,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(AppLocalizations.of(context).peakHours(vm.peakPriceLabel),
                      style: AppText.tiny),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(AppLocalizations.of(context).noHiddenFees,
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.successText)),
            ),
          ],
        ),
      );

  Widget _dateRow(DetailViewModel vm) => SizedBox(
        // Room for the pill's natural height (2×10px padding + two text lines)
        // — each item is wrapped in Center so the horizontal ListView's tight
        // cross-axis constraints can't stretch or clip it.
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: vm.dates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final d = vm.dates[i];
            final selected = vm.dateIndex == i;
            return Center(
              child: GestureDetector(
                onTap: () => vm.pickDate(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 58,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.borderLight),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(d.dow,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 10.5,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? AppColors.cream.withValues(alpha: 0.7)
                                  : AppColors.muted)),
                      const SizedBox(height: 2),
                      Text(d.day,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 17,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              color:
                                  selected ? AppColors.cream : AppColors.ink)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );

  Widget _slotGroup(BuildContext context, DetailViewModel vm, SlotGroup g) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(g.name.toUpperCase(),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.muted)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.55,
            children: [for (final s in g.slots) _slotTile(context, vm, s)],
          ),
        ],
      ),
    );
  }

  Widget _slotTile(BuildContext context, DetailViewModel vm, TimeSlot s) {
    final selected = vm.isSlotSelected(s.hour);
    final Color bg, fg, bd;
    if (selected) {
      bg = AppColors.primary;
      fg = AppColors.cream;
      bd = AppColors.primary;
    } else if (!s.available) {
      bg = const Color(0xFFEDEBE3);
      fg = AppColors.faint;
      bd = const Color(0xFFEDEBE3);
    } else {
      bg = AppColors.white;
      fg = AppColors.ink;
      bd = s.peak ? const Color(0xFFC9D8B0) : AppColors.borderLight;
    }
    return TapScale(
      scale: 0.95,
      onTap: s.available ? () => vm.pickSlot(s) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bd, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(Formatters.slotLabel(s.hour),
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: fg,
                    decoration: s.available
                        ? TextDecoration.none
                        : TextDecoration.lineThrough)),
            const SizedBox(height: 1),
            Text(
              s.available
                  ? 'TSh ${Formatters.priceK(s.price)}'
                  : AppLocalizations.of(context).unavailable,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: fg.withValues(alpha: 0.75)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _durationBanner(BuildContext context, DetailViewModel vm) {
    final loc = AppLocalizations.of(context);
    final label = vm.hasSelection ? vm.selectionLabel : loc.tapSlotsHint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text('⏱ $label',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successText)),
          ),
          const SizedBox(width: 10),
          Text(loc.liveAvailability,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successText)),
        ],
      ),
    );
  }

  Widget _amenities(List<String> items) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 4.2,
        children: [
          for (final a in items)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Text('✓',
                      style: TextStyle(
                          color: AppColors.successText,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(a,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
        ],
      );

  Widget _goodToKnow(List<String> items) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: i == items.length - 1
                      ? null
                      : const Border(
                          bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    const Text('•', style: TextStyle(color: AppColors.muted)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(items[i],
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );

  Widget _extras(BuildContext context, List<VenueExtra> extras) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            for (int i = 0; i < extras.length; i++)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: i == extras.length - 1
                      ? null
                      : const Border(
                          bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(extras[i].name,
                              style: const TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w700)),
                          Text(
                              '${Formatters.tsh(extras[i].priceTzs)} · ${AppLocalizations.of(context).perUnit(extras[i].unit)}',
                              style: AppText.tiny),
                        ],
                      ),
                    ),
                    if (!extras[i].available)
                      Text(AppLocalizations.of(context).unavailable,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.faint)),
                  ],
                ),
              ),
          ],
        ),
      );

  Widget _reviewTag(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.successBg,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(t,
            style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
      );

  Widget _reviewCard(BuildContext context, Review r) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(r.starsLabel,
                    style:
                        const TextStyle(fontSize: 11.5, color: AppColors.star)),
                Text(r.date, style: AppText.tiny),
              ],
            ),
            const SizedBox(height: 5),
            Text(r.text,
                style: TextStyle(
                    fontSize: 12.5, height: 1.5, color: AppColors.bodyText)),
            if (r.ownerReply != null && r.ownerReply!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).venueReply,
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.muted)),
                    const SizedBox(height: 3),
                    Text(r.ownerReply!,
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: AppColors.bodyText)),
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  Widget _confirmBanner(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).confirmsInstantly,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(AppLocalizations.of(context).freeCancellation,
                      style: AppText.tiny),
                ],
              ),
            ),
            const Text('⚡', style: TextStyle(fontSize: 20)),
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 12),
        child: Text(text, style: AppText.title.copyWith(fontSize: 17)),
      );
}
