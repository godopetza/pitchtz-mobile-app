import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/qr_painter.dart';
import '../../../core/utils/toast_controller.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../../di/injection.dart';
import '../../shell/viewmodel/shell_viewmodel.dart';
import '../viewmodel/booking_flow_viewmodel.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  void _goBookings(BuildContext context) {
    // Switch the shared shell to the Bookings tab, then unwind to it.
    getIt<ShellViewModel>().setIndex(1);
    Navigator.popUntil(context, ModalRoute.withName(Routes.home));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BookingFlowViewModel>();
    final bk = vm.booked;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
        children: [
          // Check badge
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.4, end: 1),
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeOutBack,
              builder: (_, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Container(
                width: 92,
                height: 92,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: Text('✓',
                    style: TextStyle(
                        color: AppColors.lime,
                        fontSize: 40,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(child: Text('Pitch booked! ⚽', style: AppText.h2.copyWith(fontSize: 27))),
          const SizedBox(height: 6),
          Center(
            child: Text("You're playing at ${bk.venue}.",
                style: TextStyle(fontSize: 14.5, color: AppColors.muted)),
          ),
          const SizedBox(height: 22),
          // Ticket card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                Text(bk.date,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(bk.time,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                      '⏱ Full ${bk.durationMinutes} guaranteed — show your code at the gate',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.successText)),
                ),
                const SizedBox(height: 14),
                const _DashedDivider(),
                const SizedBox(height: 14),
                Text('BOOKING CODE',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.muted)),
                const SizedBox(height: 4),
                Text(bk.code, style: AppText.mono),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _actionBtn('Get directions', AppColors.primary,
                    AppColors.cream, () {
                  getIt<ToastController>().show('Opening Google Maps… 🗺');
                }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionBtn('Share with team', AppColors.lime,
                    AppColors.primaryDark, vm.toggleShare),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _textLink('Add to calendar', () {}),
              const SizedBox(width: 18),
              _textLink('Split the bill', vm.toggleSplit),
            ],
          ),
          if (vm.splitOpen) ...[
            const SizedBox(height: 16),
            _splitPanel(context, vm),
          ],
          if (vm.shareOpen) ...[
            const SizedBox(height: 18),
            _sharePanel(vm),
          ],
          const SizedBox(height: 22),
          Center(
            child: GestureDetector(
              onTap: () => _goBookings(context),
              child: Text('View my bookings ›',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color bg, Color fg, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w800, color: fg)),
        ),
      );

  Widget _textLink(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary)),
      );

  Widget _splitPanel(BuildContext context, BookingFlowViewModel vm) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Split the bill',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Players',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted)),
                QuantityStepper(
                  value: vm.players,
                  onIncrement: vm.playersUp,
                  onDecrement: vm.playersDown,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('Each player pays',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted)),
                Text(vm.perPlayerFmt,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: QrCode(seed: vm.successQrSeed, size: 112),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No app? Scan & pay',
                          style: TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(
                          'Teammates scan this code and pay their share with M-Pesa or Airtel Money — no download needed.',
                          style: AppText.tiny.copyWith(height: 1.5)),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, Routes.scanPay),
                        child: Text('Preview what they see ›',
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.whatsapp,
                  borderRadius: BorderRadius.circular(10)),
              child: Text('Request via WhatsApp',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ],
        ),
      );

  Widget _sharePanel(BookingFlowViewModel vm) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invite your team',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F5E4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                  'Football booked ⚽\n${vm.booked.venue}\n${vm.booked.date}\n${vm.booked.time}\nLocation: maps link',
                  style: TextStyle(
                      fontSize: 12.5,
                      height: 1.6,
                      color: const Color(0xFF2B342D))),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _shareBtn('Send on WhatsApp', AppColors.whatsapp,
                      Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _shareBtn('Copy message', AppColors.divider,
                      AppColors.ink),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _shareBtn(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Text(label,
            style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w700, color: fg)),
      );
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const dashW = 6.0, gap = 4.0;
      final count = (c.maxWidth / (dashW + gap)).floor();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          count,
          (_) => Container(width: dashW, height: 1.5, color: AppColors.border),
        ),
      );
    });
  }
}
