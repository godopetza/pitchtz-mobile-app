import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/turf_image.dart';
import '../../../domain/entities/pitch.dart';
import '../viewmodel/explore_viewmodel.dart';

// ─── Main map view ────────────────────────────────────────────────────────────

class ExploreMapView extends StatefulWidget {
  const ExploreMapView({super.key});

  @override
  State<ExploreMapView> createState() => _ExploreMapViewState();
}

class _ExploreMapViewState extends State<ExploreMapView> {
  GoogleMapController? _ctrl;
  final _searchCtrl = TextEditingController();

  // Cache generated marker bitmaps: venueId → (normal, selected)
  final _icons = <String, (BitmapDescriptor, BitmapDescriptor)>{};
  bool _iconsReady = false;

  // Minimal map style — hide POIs and transit clutter, keep terrain visible
  static const _mapStyle = '''[
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"transit","stylers":[{"visibility":"off"}]},
    {"featureType":"road","elementType":"labels.icon","stylers":[{"visibility":"off"}]}
  ]''';

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---- Location permission + first fix ----
  Future<void> _requestLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (!mounted) return;
      final ll = LatLng(pos.latitude, pos.longitude);
      context.read<ExploreViewModel>().setUserLocation(ll);
      _ctrl?.animateCamera(CameraUpdate.newLatLngZoom(ll, 13.5));
    } catch (_) {
      // Permission denied or timeout — stay on default Dar es Salaam centre.
    }
  }

  // ---- Build custom price-label marker bitmaps ----
  Future<void> _buildIcons(List<Pitch> venues) async {
    if (_iconsReady) return;
    for (final v in venues) {
      final label = 'TSh ${Formatters.priceK(v.pricePerHour)}k';
      _icons[v.id] = (
        await _pricePinBitmap(label, selected: false),
        await _pricePinBitmap(label, selected: true),
      );
    }
    if (mounted) setState(() => _iconsReady = true);
  }

  static Future<BitmapDescriptor> _pricePinBitmap(
    String label, {
    required bool selected,
  }) async {
    const w = 110.0, h = 40.0, r = 20.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Pill background
    final bg = Paint()
      ..color = selected ? const Color(0xFF0E3B2C) : Colors.white;
    final border = Paint()
      ..color = selected ? const Color(0xFFC9F24E) : const Color(0xFF0E3B2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(r),
    );
    canvas.drawRRect(rrect, bg);
    canvas.drawRRect(rrect, border);

    // Down-pointing triangle (pin tail)
    final tail = Paint()..color = selected ? const Color(0xFF0E3B2C) : Colors.white;
    final tailBorder = Paint()
      ..color = selected ? const Color(0xFFC9F24E) : const Color(0xFF0E3B2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final tri = Path()
      ..moveTo(w / 2 - 6, h - 2)
      ..lineTo(w / 2 + 6, h - 2)
      ..lineTo(w / 2, h + 8)
      ..close();
    canvas.drawPath(tri, tail);
    canvas.drawPath(tri, tailBorder);
    // Redraw bg over triangle border overlap
    canvas.drawRRect(rrect, bg);
    canvas.drawRRect(rrect, border);

    // Price text
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: selected ? const Color(0xFFC9F24E) : const Color(0xFF0E3B2C),
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w);
    tp.paint(canvas, Offset((w - tp.width) / 2, (h - tp.height) / 2));

    final totalH = (h + 10).toInt();
    final img = await recorder.endRecording().toImage(w.toInt(), totalH);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  // ---- Build markers set ----
  Set<Marker> _buildMarkers(ExploreViewModel vm) {
    if (!_iconsReady) return {};
    return vm.venues.map((v) {
      final lat = v.latitude, lng = v.longitude;
      if (lat == null || lng == null) return null;
      final icons = _icons[v.id];
      final isSelected = vm.mapSel == v.id;
      return Marker(
        markerId: MarkerId(v.id),
        position: LatLng(lat, lng),
        icon: isSelected
            ? (icons?.$2 ?? BitmapDescriptor.defaultMarker)
            : (icons?.$1 ?? BitmapDescriptor.defaultMarker),
        zIndexInt: isSelected ? 2 : 1,
        onTap: () => vm.selectPin(v.id),
      );
    }).whereType<Marker>().toSet();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExploreViewModel>();

    // Generate icons when venues first load
    if (vm.venues.isNotEmpty && !_iconsReady) {
      _buildIcons(vm.venues);
    }

    // Respond to programmatic camera moves from the viewmodel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = vm.cameraTarget;
      if (target != null && _ctrl != null) {
        _ctrl!.animateCamera(
            CameraUpdate.newLatLngZoom(target, vm.cameraZoom));
        vm.cameraConsumed();
      }
    });

    return Padding(
      padding: const EdgeInsets.only(top: 62),
      child: Column(
        children: [
          _SearchBar(vm: vm, textCtrl: _searchCtrl),
          Expanded(
            child: Stack(
              children: [
                // Real Google Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: vm.userLocation,
                    zoom: 13.5,
                  ),
                  style: _mapStyle,
                  onMapCreated: (ctrl) {
                    _ctrl = ctrl;
                  },
                  markers: _buildMarkers(vm),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                  onTap: (_) => vm.clearMapSel(),
                ),
                // Selected venue card
                if (vm.hasMapSel)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: _MapVenueCard(pitch: vm.mapSelPitch!),
                  ),
                // Places autocomplete overlay
                if (vm.mapSearchOpen)
                  Positioned.fill(
                    child: _SearchOverlay(vm: vm, textCtrl: _searchCtrl),
                  ),
                // "Near me" FAB
                Positioned(
                  right: 16,
                  bottom: vm.hasMapSel ? 130 : 24,
                  child: _NearMeFab(onTap: _requestLocation),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.vm, required this.textCtrl});
  final ExploreViewModel vm;
  final TextEditingController textCtrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                vm.openMapSearch();
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => FocusScope.of(context).requestFocus());
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 16, color: AppColors.muted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        vm.mapQueryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    ),
                    if (vm.mapHasQuery)
                      GestureDetector(
                        onTap: vm.closeMapSearch,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.close,
                              size: 15, color: AppColors.muted),
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
              child: const Row(
                children: [
                  Text('☰',
                      style: TextStyle(color: AppColors.lime, fontSize: 12)),
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
    );
  }
}

// ─── Search overlay with autocomplete ────────────────────────────────────────

class _SearchOverlay extends StatefulWidget {
  const _SearchOverlay({required this.vm, required this.textCtrl});
  final ExploreViewModel vm;
  final TextEditingController textCtrl;

  @override
  State<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<_SearchOverlay> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return Container(
      color: AppColors.cream,
      child: Column(
        children: [
          // Input row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: widget.textCtrl,
                            focusNode: _focus,
                            autofocus: true,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Search area, pitch or venue',
                              hintStyle: TextStyle(
                                  color: AppColors.faint,
                                  fontWeight: FontWeight.w400),
                            ),
                            onChanged: vm.onSearchChanged,
                          ),
                        ),
                        if (widget.textCtrl.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              widget.textCtrl.clear();
                              vm.onSearchChanged('');
                            },
                            child: const Icon(Icons.close,
                                size: 15, color: AppColors.muted),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    widget.textCtrl.clear();
                    vm.closeMapSearch();
                  },
                  child: const Text('Cancel',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Results
          Expanded(
            child: vm.suggestionsLoading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 100),
                    children: [
                      // Google Places suggestions
                      if (vm.suggestions.isNotEmpty) ...[
                        _sectionLabel('PLACES'),
                        for (final s in vm.suggestions)
                          _suggestionRow(
                            icon: Icons.location_on_outlined,
                            title: s.mainText,
                            subtitle: s.secondaryText,
                            onTap: () {
                              widget.textCtrl.clear();
                              vm.selectSuggestion(s);
                            },
                          ),
                        const SizedBox(height: 12),
                      ],
                      // Our own venues (filter by query if any)
                      if (vm.areas.isNotEmpty) ...[
                        _sectionLabel('AREAS'),
                        for (final a in vm.areas)
                          _suggestionRow(
                            icon: Icons.grid_view_rounded,
                            title: a.name,
                            subtitle:
                                '${a.count} ${a.count == 1 ? 'pitch' : 'pitches'}',
                            onTap: () {
                              widget.textCtrl.clear();
                              vm.pickMapArea(a.name);
                            },
                          ),
                        const SizedBox(height: 12),
                      ],
                      _sectionLabel('PITCHES'),
                      for (final v in _filtered(vm))
                        _venueRow(
                          pitch: v,
                          onTap: () {
                            widget.textCtrl.clear();
                            vm.pickMapVenue(v);
                          },
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Pitch> _filtered(ExploreViewModel vm) {
    final q = widget.textCtrl.text.toLowerCase();
    if (q.isEmpty) return vm.venues;
    return vm.venues
        .where((v) =>
            v.name.toLowerCase().contains(q) ||
            v.area.toLowerCase().contains(q))
        .toList();
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
        child: Text(label, style: AppText.overline),
      );

  Widget _suggestionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.neutralFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: AppColors.muted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: AppText.tiny),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 12, color: AppColors.faint),
          ],
        ),
      ),
    );
  }

  Widget _venueRow({required Pitch pitch, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            TurfImage(
              imageUrl: pitch.imageUrl,
              gradient1: Color(pitch.gradient1),
              gradient2: Color(pitch.gradient2),
              width: 44,
              height: 40,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pitch.name,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700)),
                  Text(
                    '${pitch.area} · ★ ${pitch.ratingLabel} · From ${Formatters.tsh(pitch.pricePerHour)}/hr',
                    style: AppText.tiny,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 12, color: AppColors.faint),
          ],
        ),
      ),
    );
  }
}

// ─── Venue bottom card ────────────────────────────────────────────────────────

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
              color: AppColors.ink.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            TurfImage(
              imageUrl: pitch.imageUrl,
              gradient1: Color(pitch.gradient1),
              gradient2: Color(pitch.gradient2),
              width: 80,
              height: 76,
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
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink),
                          children: [
                            TextSpan(
                                text: Formatters.tsh(pitch.pricePerHour)),
                            const TextSpan(
                                text: '/hr',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.muted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('View →',
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.lime)),
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

// ─── Near-me FAB ─────────────────────────────────────────────────────────────

class _NearMeFab extends StatelessWidget {
  const _NearMeFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.14),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.my_location_rounded,
            size: 20, color: AppColors.primary),
      ),
    );
  }
}
