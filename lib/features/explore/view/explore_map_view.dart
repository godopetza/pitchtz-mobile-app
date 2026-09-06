import 'dart:async';
import 'dart:math' as math;
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

/// Full-screen venue map — its own page (Bolt-style): the map fills the
/// screen, the camera opens fitted around every venue pin, and searching
/// slides a smooth draggable sheet of results up from the bottom.
class VenueMapPage extends StatefulWidget {
  const VenueMapPage({super.key});

  @override
  State<VenueMapPage> createState() => _VenueMapPageState();
}

class _VenueMapPageState extends State<VenueMapPage> {
  GoogleMapController? _ctrl;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _sheetCtrl = DraggableScrollableController();

  bool _searchActive = false;
  bool _didFitAll = false;

  // Cache generated marker bitmaps: venueId → (normal, selected)
  final _icons = <String, (BitmapDescriptor, BitmapDescriptor)>{};
  bool _iconsReady = false;
  bool _buildingIcons = false;

  // Clean, Bolt-like light map: muted POIs, white roads, soft water.
  static const _mapStyle = '''[
    {"featureType":"all","elementType":"labels.text.fill",
      "stylers":[{"color":"#616161"}]},
    {"featureType":"all","elementType":"labels.text.stroke",
      "stylers":[{"color":"#f5f5f5"}]},
    {"featureType":"poi","elementType":"geometry",
      "stylers":[{"color":"#eeeeee"}]},
    {"featureType":"poi","elementType":"labels.text.fill",
      "stylers":[{"color":"#757575"}]},
    {"featureType":"poi.business","stylers":[{"visibility":"off"}]},
    {"featureType":"poi.park","elementType":"geometry",
      "stylers":[{"color":"#d5e8d4"}]},
    {"featureType":"poi.park","elementType":"labels.text.fill",
      "stylers":[{"color":"#6b9a76"}]},
    {"featureType":"poi.sports_complex","elementType":"geometry",
      "stylers":[{"color":"#c8e6c9"}]},
    {"featureType":"road","elementType":"geometry",
      "stylers":[{"color":"#ffffff"}]},
    {"featureType":"road.arterial","elementType":"labels.text.fill",
      "stylers":[{"color":"#757575"}]},
    {"featureType":"road.highway","elementType":"geometry",
      "stylers":[{"color":"#e8e8e8"}]},
    {"featureType":"road.local","elementType":"labels.text.fill",
      "stylers":[{"color":"#9e9e9e"}]},
    {"featureType":"transit","stylers":[{"visibility":"off"}]},
    {"featureType":"water","elementType":"geometry",
      "stylers":[{"color":"#a2daf2"}]},
    {"featureType":"water","elementType":"labels.text.fill",
      "stylers":[{"color":"#3d5b7a"}]},
    {"featureType":"landscape","elementType":"geometry",
      "stylers":[{"color":"#f5f5f0"}]}
  ]''';

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus && !_searchActive) _openSearch();
    });
    _requestLocation();
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _sheetCtrl.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searchActive = true);
    context.read<ExploreViewModel>().openMapSearch();
  }

  void _closeSearch() {
    _searchCtrl.clear();
    _searchFocus.unfocus();
    setState(() => _searchActive = false);
    context.read<ExploreViewModel>().closeMapSearch();
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
      context
          .read<ExploreViewModel>()
          .setUserLocation(LatLng(pos.latitude, pos.longitude));
    } catch (_) {
      // Stay on the default Dar es Salaam centre.
    }
  }

  void _goToMyLocation() {
    final ll = context.read<ExploreViewModel>().userLocation;
    _ctrl?.animateCamera(CameraUpdate.newLatLngZoom(ll, 15));
  }

  // ---- Fit the camera around every venue pin ----
  void _fitAllVenues(List<Pitch> venues) {
    if (_didFitAll || _ctrl == null) return;
    final coords = venues
        .where((v) => v.latitude != null && v.longitude != null)
        .map((v) => LatLng(v.latitude!, v.longitude!))
        .toList();
    if (coords.isEmpty) return;
    _didFitAll = true;

    if (coords.length == 1) {
      _ctrl!.animateCamera(CameraUpdate.newLatLngZoom(coords.first, 14));
      return;
    }
    var minLat = coords.first.latitude, maxLat = coords.first.latitude;
    var minLng = coords.first.longitude, maxLng = coords.first.longitude;
    for (final c in coords) {
      minLat = math.min(minLat, c.latitude);
      maxLat = math.max(maxLat, c.latitude);
      minLng = math.min(minLng, c.longitude);
      maxLng = math.max(maxLng, c.longitude);
    }
    _ctrl!.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      ),
      70, // padding so edge pins aren't clipped
    ));
  }

  // ---- Build custom price-label marker bitmaps ----
  Future<void> _buildIcons(List<Pitch> venues) async {
    if (_iconsReady || _buildingIcons) return;
    _buildingIcons = true;
    for (final v in venues) {
      final label = Formatters.tsh(v.pricePerHour);
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
    const double r = 22;
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: selected ? const Color(0xFFC9F24E) : const Color(0xFF0E3B2C),
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double pw = tp.width + 24;
    const double ph = r * 2;
    const double tailH = 9;
    final double totalH = ph + tailH;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final shadowPaint = Paint()
      ..color = const Color(0x30000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(2, 4, pw, ph), const Radius.circular(r)),
      shadowPaint,
    );

    final bgPaint = Paint()
      ..color = selected ? const Color(0xFF0E3B2C) : Colors.white;
    final borderPaint = Paint()
      ..color = const Color(0xFF0E3B2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, pw, ph), const Radius.circular(r));

    final tailPaint = Paint()
      ..color = selected ? const Color(0xFF0E3B2C) : Colors.white;
    final tri = Path()
      ..moveTo(pw / 2 - 5, ph)
      ..lineTo(pw / 2 + 5, ph)
      ..lineTo(pw / 2, ph + tailH)
      ..close();
    canvas.drawPath(tri, tailPaint);

    canvas.drawRRect(rrect, bgPaint);
    if (!selected) canvas.drawRRect(rrect, borderPaint);

    tp.paint(canvas, Offset((pw - tp.width) / 2, (ph - tp.height) / 2));

    final img =
        await recorder.endRecording().toImage(pw.ceil(), totalH.ceil());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List(),
        imagePixelRatio: 2);
  }

  Set<Marker> _buildMarkers(ExploreViewModel vm) {
    return vm.venues.map((v) {
      final lat = v.latitude, lng = v.longitude;
      if (lat == null || lng == null) return null;
      final isSelected = vm.mapSel == v.id;
      BitmapDescriptor icon;
      final cached = _icons[v.id];
      if (_iconsReady && cached != null) {
        icon = isSelected ? cached.$2 : cached.$1;
      } else {
        icon = isSelected
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
            : BitmapDescriptor.defaultMarkerWithHue(50);
      }
      return Marker(
        markerId: MarkerId(v.id),
        position: LatLng(lat, lng),
        icon: icon,
        zIndexInt: isSelected ? 2 : 1,
        onTap: () {
          if (_searchActive) _closeSearch();
          vm.selectPin(v.id);
        },
      );
    }).whereType<Marker>().toSet();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExploreViewModel>();
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    if (vm.venues.isNotEmpty && !_iconsReady) _buildIcons(vm.venues);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fit around all pins once venues + controller are both ready.
      if (!_didFitAll && vm.venues.isNotEmpty) _fitAllVenues(vm.venues);
      // Programmatic camera moves (search result / area picked).
      final target = vm.cameraTarget;
      if (target != null && _ctrl != null) {
        _ctrl!
            .animateCamera(CameraUpdate.newLatLngZoom(target, vm.cameraZoom));
        vm.cameraConsumed();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.cream,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Full-screen map ──────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: vm.userLocation, zoom: 12.5),
            style: _mapStyle,
            onMapCreated: (ctrl) {
              _ctrl = ctrl;
              if (vm.venues.isNotEmpty) _fitAllVenues(vm.venues);
            },
            markers: _buildMarkers(vm),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            onTap: (_) {
              if (_searchActive) _closeSearch();
              vm.clearMapSel();
            },
          ),

          // ── Top bar: back + live search field ────────────────────────────
          Positioned(
            top: top + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _CircleBtn(
                  onTap: () {
                    if (_searchActive) {
                      _closeSearch();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 17, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            size: 18, color: AppColors.muted),
                        const SizedBox(width: 9),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            focusNode: _searchFocus,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Search place, area or venue',
                              hintStyle: TextStyle(
                                  color: AppColors.faint,
                                  fontWeight: FontWeight.w400),
                            ),
                            onTap: _openSearch,
                            onChanged: (q) {
                              vm.onSearchChanged(q);
                              setState(() {}); // refresh clear button
                            },
                          ),
                        ),
                        if (_searchCtrl.text.isNotEmpty || _searchActive)
                          GestureDetector(
                            onTap: _closeSearch,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.close,
                                  size: 17, color: AppColors.muted),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Right-side controls ──────────────────────────────────────────
          if (!_searchActive && !vm.hasMapSel)
            Positioned(
              right: 14,
              bottom: bottom + 96,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CircleBtn(
                    onTap: _goToMyLocation,
                    child: const Icon(Icons.my_location_rounded,
                        size: 19, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  _CircleBtn(
                    onTap: () => _ctrl?.animateCamera(CameraUpdate.zoomIn()),
                    child: const Icon(Icons.add,
                        size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  _CircleBtn(
                    onTap: () => _ctrl?.animateCamera(CameraUpdate.zoomOut()),
                    child: const Icon(Icons.remove,
                        size: 20, color: AppColors.primary),
                  ),
                ],
              ),
            ),

          // ── Venue count bubble ───────────────────────────────────────────
          if (!_searchActive && !vm.hasMapSel && vm.venues.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: bottom + 24,
              child: Center(child: _VenueCountBubble(count: vm.venues.length)),
            ),

          // ── Selected venue card ──────────────────────────────────────────
          if (vm.hasMapSel && !_searchActive)
            Positioned(
              left: 16,
              right: 16,
              bottom: bottom + 16,
              child: _MapVenueCard(pitch: vm.mapSelPitch!),
            ),

          // ── Search results: smooth draggable bottom sheet over the map ──
          // Padded by the keyboard inset so the sheet rides above the
          // keyboard instead of being covered by it.
          if (_searchActive)
            AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: DraggableScrollableSheet(
                controller: _sheetCtrl,
                initialChildSize: 0.45,
                minChildSize: 0.25,
                maxChildSize: 0.88,
                snap: true,
                snapSizes: const [0.45, 0.88],
                builder: (context, scrollCtrl) => _ResultsSheet(
                  vm: vm,
                  scrollCtrl: scrollCtrl,
                  query: _searchCtrl.text,
                  onPlaceTap: (s) {
                    vm.selectSuggestion(s);
                    _closeSearch();
                  },
                  onAreaTap: (name) {
                    vm.pickMapArea(name);
                    _closeSearch();
                  },
                  onVenueTap: (v) {
                    vm.pickMapVenue(v);
                    _closeSearch();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Results bottom sheet ─────────────────────────────────────────────────────

class _ResultsSheet extends StatelessWidget {
  const _ResultsSheet({
    required this.vm,
    required this.scrollCtrl,
    required this.query,
    required this.onPlaceTap,
    required this.onAreaTap,
    required this.onVenueTap,
  });

  final ExploreViewModel vm;
  final ScrollController scrollCtrl;
  final String query;
  final ValueChanged<PlaceSuggestion> onPlaceTap;
  final ValueChanged<String> onAreaTap;
  final ValueChanged<Pitch> onVenueTap;

  List<Pitch> get _filteredVenues {
    final q = query.toLowerCase();
    if (q.isEmpty) return vm.venues.take(12).toList();
    return vm.venues
        .where((v) =>
            v.name.toLowerCase().contains(q) ||
            v.area.toLowerCase().contains(q))
        .toList();
  }

  List<Area> get _filteredAreas {
    final q = query.toLowerCase();
    if (q.isEmpty) return vm.areas;
    return vm.areas.where((a) => a.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // Grab handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (vm.suggestionsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            )
          else ...[
            if (vm.suggestions.isNotEmpty) ...[
              _sectionLabel('PLACES'),
              for (final s in vm.suggestions)
                _ResultRow(
                  icon: Icons.location_on_outlined,
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2E7D32),
                  title: s.mainText,
                  subtitle: s.secondaryText,
                  onTap: () => onPlaceTap(s),
                ),
            ],
            if (_filteredAreas.isNotEmpty) ...[
              _sectionLabel('AREAS'),
              for (final a in _filteredAreas)
                _ResultRow(
                  icon: Icons.grid_view_rounded,
                  iconBg: const Color(0xFFF3E5F5),
                  iconColor: const Color(0xFF7B1FA2),
                  title: a.name,
                  subtitle: '${a.count} ${a.count == 1 ? 'pitch' : 'pitches'}',
                  onTap: () => onAreaTap(a.name),
                ),
            ],
            _sectionLabel('VENUES'),
            if (_filteredVenues.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text('No venues match "$query"',
                    style: AppText.bodyMuted),
              )
            else
              for (final v in _filteredVenues)
                _VenueRow(pitch: v, onTap: () => onVenueTap(v)),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
        child: Text(label,
            style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.muted)),
      );
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: AppText.tiny.copyWith(fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.north_west, size: 13, color: AppColors.faint),
          ],
        ),
      ),
    );
  }
}

class _VenueRow extends StatelessWidget {
  const _VenueRow({required this.pitch, required this.onTap});
  final Pitch pitch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        child: Row(
          children: [
            TurfImage(
              imageUrl: pitch.imageUrl,
              gradient1: Color(pitch.gradient1),
              gradient2: Color(pitch.gradient2),
              width: 48,
              height: 44,
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
                    style: AppText.tiny.copyWith(fontSize: 12),
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

// ─── Venue count bubble ───────────────────────────────────────────────────────

class _VenueCountBubble extends StatelessWidget {
  const _VenueCountBubble({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '$count ${count == 1 ? 'venue' : 'venues'} on map',
        style: const TextStyle(
          color: AppColors.lime,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 24,
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
              width: 84,
              height: 78,
              borderRadius: BorderRadius.circular(13),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pitch.verified)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 13, color: Color(0xFF2E7D32)),
                          SizedBox(width: 4),
                          Text('Verified',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32))),
                        ],
                      ),
                    ),
                  Text(pitch.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink)),
                  const SizedBox(height: 3),
                  Text('${pitch.area} · ★ ${pitch.ratingLabel}',
                      style: AppText.tiny.copyWith(fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
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
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Book →',
                            style: TextStyle(
                                fontSize: 12,
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

// ─── Reusable circle button ───────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
