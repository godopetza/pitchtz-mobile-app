import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../viewmodel/booking_flow_viewmodel.dart';

/// Payment confirmation splash. After 2.2s it finalises the booking and moves
/// to the success screen (design's `startPay` timeout).
class ProcessingPage extends StatefulWidget {
  const ProcessingPage({super.key});

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      context.read<BookingFlowViewModel>().confirm();
      Navigator.pushReplacementNamed(context, Routes.success);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<BookingFlowViewModel>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _BlinkingDots(),
            const SizedBox(height: 22),
            Text('Confirming payment…',
                style: AppText.title.copyWith(color: AppColors.cream)),
            const SizedBox(height: 22),
            Text('Check your phone for the ${vm.payName} prompt',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.cream.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }
}

class _BlinkingDots extends StatefulWidget {
  const _BlinkingDots();

  @override
  State<_BlinkingDots> createState() => _BlinkingDotsState();
}

class _BlinkingDotsState extends State<_BlinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              final t = ((_c.value + i * 0.2) % 1.0);
              final opacity = 0.25 + 0.75 * (1 - (2 * t - 1).abs());
              return Opacity(
                opacity: opacity,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                      color: AppColors.lime, shape: BoxShape.circle),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
