import 'package:flutter/material.dart';

/// Reproduces the design's turf background: an Unsplash photo laid over a
/// repeating vertical two-tone green "mowed grass" gradient. The gradient shows
/// through while the photo loads (or if it fails), exactly like the CSS
/// `url(...) , repeating-linear-gradient(90deg, g1 0 26px, g2 26px 52px)`.
class TurfImage extends StatelessWidget {
  const TurfImage({
    super.key,
    this.imageUrl,
    required this.gradient1,
    required this.gradient2,
    this.width,
    this.height,
    this.borderRadius,
    this.child,
  });

  /// Full photo URL (e.g. a venue photo). When null/empty only the gradient
  /// shows — which is the common case today, as most venues have no photos yet.
  final String? imageUrl;
  final Color gradient1;
  final Color gradient2;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = imageUrl != null && imageUrl!.isNotEmpty;
    final content = Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _StripePainter(gradient1, gradient2)),
        if (hasPhoto)
          Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, wasSync) {
              if (wasSync) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 350),
                child: child,
              );
            },
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        if (child != null) child!,
      ],
    );

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(width: width, height: height, child: content),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter(this.c1, this.c2);

  final Color c1;
  final Color c2;
  static const double band = 26;

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()..color = c1;
    final p2 = Paint()..color = c2;
    int i = 0;
    for (double x = 0; x < size.width; x += band, i++) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, band, size.height),
        i.isEven ? p1 : p2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StripePainter old) =>
      old.c1 != c1 || old.c2 != c2;
}
