import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Renders a decorative, deterministic QR-style code identical to the design's
/// `qr(seed, size)` routine (a seeded LCG deciding which modules are filled,
/// plus the three fixed finder patterns). It is illustrative only.
class QrCode extends StatelessWidget {
  const QrCode({super.key, required this.seed, this.size = 104});

  final int seed;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size, size),
        painter: _QrPainter(seed),
      );
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.seed);

  final int seed;
  static const int n = 21;

  List<List<int>> _finder(int x, int y) {
    final r = <List<int>>[];
    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < 7; j++) {
        final edge = i == 0 || i == 6 || j == 0 || j == 6;
        final core = i >= 2 && i <= 4 && j >= 2 && j <= 4;
        if (edge || core) r.add([x + j, y + i]);
      }
    }
    return r;
  }

  bool _inFinder(int x, int y) =>
      (x < 8 && y < 8) || (x > 12 && y < 8) || (x < 8 && y > 12);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppColors.white;
    canvas.drawRect(Offset.zero & size, bg);

    final cells = <List<int>>[];
    // Linear congruential generator seeded identically to the design.
    int s = seed;
    double rnd() {
      s = (s * 1103515245 + 12345) % 2147483648;
      return s / 2147483648;
    }

    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        if (!_inFinder(x, y) && rnd() > 0.52) cells.add([x, y]);
      }
    }

    final all = <List<int>>[
      ..._finder(0, 0),
      ..._finder(14, 0),
      ..._finder(0, 14),
      ...cells,
    ];

    final c = size.width / n;
    final module = Paint()..color = AppColors.ink;
    for (final p in all) {
      canvas.drawRect(
        Rect.fromLTWH(p[0] * c, p[1] * c, c * 0.92, c * 0.92),
        module,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) => old.seed != seed;
}
