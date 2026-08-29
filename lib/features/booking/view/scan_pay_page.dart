import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/qr_painter.dart';

/// The mobile-web "scan & pay" page a teammate sees when paying their share
/// without the app.
class ScanPayPage extends StatelessWidget {
  const ScanPayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scanPayBg,
      body: ListView(
        padding: const EdgeInsets.only(top: 54),
        children: [
          // Fake browser chrome
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('✕',
                      style: TextStyle(fontSize: 15, color: AppColors.muted)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('🔒 pay.pitchtz.co.tz/s/PITCH-7284',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text('MOBILE WEB · NO APP NEEDED',
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.faint)),
          ),
          const SizedBox(height: 4),
          // Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2.5),
                    ),
                    child: Center(
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Pay for your session',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text('Mikocheni Arena · Tonight 8:00 PM',
                    style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const QrCode(seed: 42, size: 168),
                ),
                const SizedBox(height: 8),
                Text('Session code PITCH-7284 · organized by Juma M.',
                    style: TextStyle(fontSize: 11, color: AppColors.faint)),
                const SizedBox(height: 14),
                const _DashedLine(),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('Your share',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted)),
                    Text(Formatters.tsh(7800),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _payBtn('Pay with M-Pesa', filled: true),
                const SizedBox(height: 8),
                _payBtn('Airtel Money'),
                const SizedBox(height: 8),
                _payBtn('Mixx by Yas'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 14, 30, 30),
            child: Text(
                "You'll get an SMS receipt. Payment goes to the booking on Pitch TZ.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11.5, height: 1.5, color: AppColors.faint)),
          ),
        ],
      ),
    );
  }

  Widget _payBtn(String label, {bool filled = false}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(13),
          border: filled
              ? null
              : Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: filled ? FontWeight.w800 : FontWeight.w700,
                color: filled ? AppColors.cream : AppColors.ink)),
      );
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const dashW = 6.0, gap = 4.0;
      final count = (c.maxWidth / (dashW + gap)).floor();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(count,
            (_) => Container(width: dashW, height: 1.5, color: AppColors.border)),
      );
    });
  }
}
