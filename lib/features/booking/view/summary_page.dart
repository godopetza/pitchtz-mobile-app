import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/qr_painter.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../../core/widgets/turf_image.dart';
import '../../../domain/entities/booking.dart';
import '../viewmodel/booking_flow_viewmodel.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BookingFlowViewModel>();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 62, 20, 40),
        children: [
          // Header
          Row(
            children: [
              CircleIconButton(
                border: AppColors.border,
                onTap: () => Navigator.pop(context),
                child: const Text('‹', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Text('Confirm booking', style: AppText.h3),
            ],
          ),
          const SizedBox(height: 18),
          // Venue card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                TurfImage(
                  imageUrl: vm.pitch.imageUrl,
                  gradient1: Color(vm.pitch.gradient1),
                  gradient2: Color(vm.pitch.gradient2),
                  width: 72,
                  height: 72,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vm.pitch.name, style: AppText.cardTitle),
                      const SizedBox(height: 2),
                      Text('${vm.pitch.area}, Dar es Salaam',
                          style: AppText.small),
                      Text('✓ Verified venue',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.successText)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Summary rows
          Container(
            decoration: _cardDecoration(),
            child: Column(
              children: [
                for (int i = 0; i < vm.summaryRows.length; i++)
                  _kvRow(vm.summaryRows[i],
                      last: i == vm.summaryRows.length - 1),
              ],
            ),
          ),
          _sectionTitle('Extras for your game'),
          _extras(vm),
          _sectionTitle('Repeat this booking'),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final r in vm.repeatOptions)
                _chip(r, vm.repeat == r, () => vm.pickRepeat(r)),
            ],
          ),
          const SizedBox(height: 7),
          Text(vm.repeatNote, style: AppText.tiny),
          _sectionTitleRich('Support the venue', ' · optional'),
          _tipRow(
            title: 'Tip the security guards',
            subtitle: 'Goes directly to the guards fund',
            amount: 'TSh 2,000',
            checked: vm.tipGuards,
            onTap: vm.toggleTip,
          ),
          const SizedBox(height: 8),
          _tipRow(
            title: 'Venue contribution',
            subtitle: 'Helps maintain the pitch',
            amount: 'TSh 5,000',
            checked: vm.contribute,
            onTap: vm.toggleContribute,
          ),
          const SizedBox(height: 20),
          _priceBreakdown(vm),
          _sectionTitle('Payment plan'),
          _paymentPlan(vm),
          _sectionTitle('Payment method'),
          _paymentMethods(vm),
          _sectionTitle("Who's paying?"),
          _whoPaying(vm),
          if (vm.splitPay) ...[
            const SizedBox(height: 10),
            _splitPanel(vm),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: vm.payButtonLabel,
            onTap: () => Navigator.pushNamed(context, Routes.processing),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text("You won't be charged until the venue confirms.",
                style: AppText.tiny),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      );

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Text(t, style: AppText.title),
      );

  Widget _sectionTitleRich(String t, String muted) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: RichText(
          text: TextSpan(
            style: AppText.title,
            children: [
              TextSpan(text: t),
              TextSpan(
                  text: muted,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted)),
            ],
          ),
        ),
      );

  Widget _kvRow(PriceLine r, {bool last = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(r.label,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted)),
            Flexible(
              child: Text(r.value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

  Widget _extras(BookingFlowViewModel vm) => Container(
        decoration: _cardDecoration(),
        child: Column(
          children: [
            for (int i = 0; i < vm.extraDefs.length; i++)
              Builder(builder: (_) {
                final x = vm.extraDefs[i];
                final isWater = x.key == 'water';
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: i == vm.extraDefs.length - 1
                        ? null
                        : const Border(
                            bottom: BorderSide(color: AppColors.divider)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(x.name,
                                    style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700)),
                                Text(
                                    '${x.description} · ${Formatters.tsh(x.price)}',
                                    style: AppText.tiny),
                              ],
                            ),
                          ),
                          QuantityStepper(
                            value: vm.qty(x.key),
                            canDecrement: vm.qty(x.key) > 0,
                            onIncrement: () => vm.increment(x.key),
                            onDecrement: () => vm.decrement(x.key),
                          ),
                        ],
                      ),
                      if (isWater) ...[
                        const SizedBox(height: 9),
                        GestureDetector(
                          onTap: vm.toggleWaterAlways,
                          child: Row(
                            children: [
                              _switch(vm.waterAlways),
                              const SizedBox(width: 8),
                              Text('Add 3 cartons to every booking',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.muted)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
          ],
        ),
      );

  Widget _switch(bool on) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38,
        height: 22,
        decoration: BoxDecoration(
          color: on ? AppColors.primary : AppColors.inputBorder,
          borderRadius: BorderRadius.circular(11),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ),
      );

  Widget _chip(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(99),
            border:
                Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.cream : AppColors.bodyText)),
        ),
      );

  Widget _tipRow({
    required String title,
    required String subtitle,
    required String amount,
    required bool checked,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: checked ? AppColors.primary : AppColors.borderLight,
                width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: checked ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: checked
                    ? Text('✓',
                        style: TextStyle(
                            color: AppColors.lime,
                            fontSize: 12,
                            fontWeight: FontWeight.w800))
                    : null,
              ),
              const SizedBox(width: 11),
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
              Text(amount,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );

  Widget _priceBreakdown(BookingFlowViewModel vm) => Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            _line('Pitch fee', vm.pitchFeeFmt),
            for (final l in vm.extraLines) _line(l.label, l.value),
            _line('Service fee', 'TSh 3,000'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
                  Text(vm.totalFmt,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _line(String k, String v) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 11, 16, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: TextStyle(fontSize: 13.5, color: AppColors.muted)),
            Text(v,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _paymentPlan(BookingFlowViewModel vm) => Column(
        children: [
          _radioTile(
            title: 'Pay in full',
            subtitle: 'One payment, done',
            trailing: vm.totalFmt,
            selected: !vm.installment,
            onTap: vm.pickFull,
          ),
          const SizedBox(height: 8),
          _radioTile(
            title: 'Split in 2 payments',
            subtitle: '50% now · balance due before play day',
            trailing: '${vm.payNowFmt} now',
            selected: vm.installment,
            onTap: vm.pickInstallment,
          ),
        ],
      );

  Widget _radioTile({
    required String title,
    required String subtitle,
    required String trailing,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.borderLight,
                width: 1.5),
          ),
          child: Row(
            children: [
              _radio(selected),
              const SizedBox(width: 11),
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
              Text(trailing,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );

  Widget _radio(bool selected) => Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ),
      );

  Widget _paymentMethods(BookingFlowViewModel vm) => Column(
        children: [
          for (final m in vm.paymentMethods) ...[
            GestureDetector(
              onTap: () => vm.pickPayment(m.id),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: vm.payId == m.id
                          ? AppColors.primary
                          : AppColors.borderLight,
                      width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(m.brandColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(m.mark,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          Text(m.subtitle, style: AppText.tiny),
                        ],
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: vm.payId == m.id
                                ? AppColors.primary
                                : AppColors.handle,
                            width: 2),
                      ),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: vm.payId == m.id
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      );

  Widget _whoPaying(BookingFlowViewModel vm) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.neutralFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _segment('Just me', !vm.splitPay, vm.setSolo),
            _segment('Split with group', vm.splitPay, vm.setSplit),
          ],
        ),
      );

  Widget _segment(String label, bool selected, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.ink : AppColors.muted)),
          ),
        ),
      );

  Widget _splitPanel(BookingFlowViewModel vm) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SPLIT WITH', style: AppText.overline.copyWith(color: AppColors.muted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final g in vm.splitGroups)
                  _chip(g, vm.splitGroup == g, () => vm.pickSplitGroup(g)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Players splitting',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted)),
                QuantityStepper(
                  value: vm.splitN,
                  onIncrement: vm.splitUp,
                  onDecrement: vm.splitDown,
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
                Text('Each pays',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted)),
                Text(vm.splitShareFmt,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
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
                  child: QrCode(seed: vm.splitQrSeed, size: 104),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Others scan to pay their share',
                          style: TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(
                          'Works without the app — M-Pesa, Airtel Money or card. Booking confirms when everyone has paid, or you can cover the rest.',
                          style: AppText.tiny.copyWith(height: 1.5)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _smallBtn('WhatsApp link', AppColors.whatsapp,
                              Colors.white),
                          const SizedBox(width: 7),
                          _smallBtn('Copy link', AppColors.divider, AppColors.ink),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _smallBtn(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
      );
}
