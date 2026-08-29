import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/map_backdrop.dart';
import '../../../core/widgets/turf_image.dart';
import '../../../domain/entities/pitch.dart';
import '../viewmodel/explore_viewmodel.dart';

/// Projects venue lat/lng onto fractional (0..1) positions inside the stylised
/// map using the bounding box of all venues, padded so pins stay on-screen.
class MapProjection {
  MapProjection(List<Pitch> venues) {
    final withCoords = venues
        .where((v) => v.latitude != null && v.longitude != null)
        .toList();
    if (withCoords.isEmpty) return;
    _minLat = withCoords.map((v) => v.latitude!).reduce((a, b) => a < b ? a : b);
    _maxLat = withCoords.map((v) => v.latitude!).reduce((a, b) => a > b ? a : b);
    _minLng =
        withCoords.map((v) => v.longitude!).reduce((a, b) => a < b ? a : b);
    _maxLng =
        withCoords.map((v) => v.longitude!).reduce((a, b) => a > b ? a : b);
  }

  double? _minLat, _maxLat, _minLng, _maxLng;

  /// (x, y) fractions with 15% padding; deterministic spread when coords are
  /// missing or all identical.
  (double, double) project(Pitch v, int index, int total) {
    const pad = 0.15;
    final lat = v.latitude, lng = v.longitude;
    if (lat == null ||
        lng == null ||
        _minLat == null ||
        _maxLat == _minLat ||
        _maxLng == _minLng) {
      // Fallback: spread pins evenly on a diagonal band.
      final t = total <= 1 ? 0.5 : index / (total - 1);
      return (pad + t * (1 - 2 * pad), 0.25 + 0.5 * ((index * 7) % 10) / 10);
    }
    final x = (lng - _minLng!) / (_maxLng! - _minLng!);
    final y = 1 - (lat - _minLat!) / (_maxLat! - _minLat!); // north = up
    return (pad + x * (1 - 2 * pad), pad + y * (1 - 2 * pad));
  }
}

/// The full-screen map variant of the Explore tab.
class ExploreMapView extends StatelessWidget {
  const ExploreMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExploreViewModel>();
    final projection = MapProjection(vm.venues);

    return Padding(
      padding: const EdgeInsets.only(top: 62),
      child: Column(
        children: [
          // Search + list toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: vm.toggleMapSearch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              size: 16, color: AppColors.muted),
                          const SizedBox(width: 10),
                          Text(
                            vm.mapQueryLabel,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: vm.mapHasQuery
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: vm.mapHasQuery
                                  ? AppColors.ink
                                  : AppColors.faint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: vm.showList,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: const [
                        Text('☰',
                            style:
                                TextStyle(color: AppColors.lime, fontSize: 12)),
                        SizedBox(width: 7),
                        Text('List',
                            style: TextStyle(
                                color: AppColors.cream,
                                fontSize: 13,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: MapBackdrop(
                    showUserDot: true,
                    overlayBuilder: (size) => Stack(
                      children: [
                        for (int i = 0; i < vm.venues.length; i++)
                          Builder(builder: (_) {
                            final p = vm.venues[i];
                            final (fx, fy) =
                                projection.project(p, i, vm.venues.length);
                            return Positioned(
                              left: fx * size.width,
                              top: fy * size.height,
                              child: FractionalTranslation(
                                translation: const Offset(-0.5, -1),
                                child: MapPin(
                                  label: Formatters.priceK(p.pricePerHour),
                                  selected: vm.mapSel == p.id,
                                  onTap: () => vm.selectPin(p.id),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                if (vm.hasMapSel)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: _MapVenueCard(pitch: vm.mapSelPitch!),
                  ),
                if (vm.mapSearchOpen)
                  Positioned.fill(child: _MapSearchPanel(vm: vm)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapVenueCard extends StatelessWidget {
  const _MapVenueCard({required this.pitch});
  final Pitch pitch;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, Routes.detail, arguments: pitch.id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            TurfImage(
              imageUrl: pitch.imageUrl,
              gradient1: Color(pitch.gradient1),
              gradient2: Color(pitch.gradient2),
              width: 78,
              height: 74,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pitch.name, style: AppText.cardTitle),
                  const SizedBox(height: 2),
                  Text('${pitch.area} · ★ ${pitch.ratingLabel}',
                      style: AppText.tiny),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink),
                          children: [
                            TextSpan(text: Formatters.tsh(pitch.pricePerHour)),
                            TextSpan(
                                text: '/hr',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.muted)),
                          ],
                        ),
                      ),
                      if (pitch.verified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('✓ Verified',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.successText)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapSearchPanel extends StatelessWidget {
  const _MapSearchPanel({required this.vm});
  final ExploreViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cream,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 110),
      child: ListView(
        children: [
          if (vm.areas.isNotEmpty) ...[
            Text('AREAS', style: AppText.overline),
            const SizedBox(height: 8),
            for (final a in vm.areas)
              _row(
                icon: '◎',
                title: a.name,
                subtitle: '${a.count} ${a.count == 1 ? 'pitch' : 'pitches'}',
                onTap: () => vm.pickMapArea(a.name),
              ),
            const SizedBox(height: 16),
          ],
          Text('PITCHES', style: AppText.overline),
          const SizedBox(height: 8),
          for (final v in vm.venues)
            _row(
              turfPitch: v,
              title: v.name,
              subtitle:
                  '${v.area} · ★ ${v.ratingLabel} · From ${Formatters.tsh(v.pricePerHour)}/hr',
              onTap: () => vm.pickMapVenue(v),
            ),
        ],
      ),
    );
  }

  Widget _row({
    String? icon,
    Pitch? turfPitch,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderLight)),
        ),
        child: Row(
          children: [
            if (icon != null)
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.neutralFill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(icon,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 14)),
              )
            else
              TurfImage(
                imageUrl: turfPitch!.imageUrl,
                gradient1: Color(turfPitch.gradient1),
                gradient2: Color(turfPitch.gradient2),
                width: 42,
                height: 38,
                borderRadius: BorderRadius.circular(10),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700)),
                  Text(subtitle, style: AppText.tiny),
                ],
              ),
            ),
            const Text('›', style: TextStyle(color: AppColors.faint)),
          ],
        ),
      ),
    );
  }
}
