import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The stylised static "map" used on the explore-map and results-map screens:
/// a grid, a few diagonal "roads", and the Indian Ocean in the corner. Pins are
/// layered on top by the caller via a Stack.
class MapBackdrop extends StatelessWidget {
  const MapBackdrop({
    super.key,
    this.showUserDot = false,
    this.children = const [],
    this.overlayBuilder,
  });

  final bool showUserDot;
  final List<Widget> children;

  /// Builds size-aware content (e.g. fractionally-positioned pins) laid over
  /// the map. Receives the resolved map [Size].
  final Widget Function(Size size)? overlayBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return ClipRect(
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: AppColors.mapBg)),
              Positioned.fill(child: CustomPaint(painter: _GridPainter())),
              // Roads
              _road(left: -0.10 * w, top: 0.08 * h, width: 0.70 * w, height: 26, angle: -0.24),
              _road(left: 0.30 * w, top: -0.05 * h, width: 22, height: 0.80 * h, angle: 0.16),
              _road(left: 0.40 * w, top: 0.26 * h, width: 0.60 * w, height: 24, angle: 0.37),
              // Ocean
              Positioned(
                right: -0.14 * w,
                bottom: -0.12 * h,
                child: Container(
                  width: 0.52 * w,
                  height: 0.44 * h,
                  decoration: const BoxDecoration(
                    color: AppColors.mapWater,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.elliptical(120, 90),
                      topRight: Radius.elliptical(120, 90),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0.06 * w,
                bottom: 0.16 * h,
                child: Text(
                  'Indian Ocean',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mapWaterLabel,
                  ),
                ),
              ),
              if (showUserDot)
                Positioned(
                  left: 0.46 * w,
                  top: 0.55 * h,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.mapUser,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mapUser.withValues(alpha: 0.18),
                          blurRadius: 0,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              if (overlayBuilder != null)
                Positioned.fill(child: overlayBuilder!(Size(w, h))),
              ...children,
            ],
          ),
        );
      },
    );
  }

  Widget _road({
    required double left,
    required double top,
    required double width,
    required double height,
    required double angle,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const step = 52.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A price pin dropped on the map (selected pins invert colours).
class MapPin extends StatelessWidget {
  const MapPin({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.lime : AppColors.ink,
              ),
            ),
          ),
          Container(width: 2, height: 6, color: Colors.white),
        ],
      ),
    );
  }
}
