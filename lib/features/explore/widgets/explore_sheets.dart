import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../../domain/entities/city.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../viewmodel/explore_viewmodel.dart';

Widget _handle() => Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.handle,
        borderRadius: BorderRadius.circular(2),
      ),
    );

/// Bottom sheet: choose your city (live from `GET /v1/cities`). Waitlist
/// cities offer a "Notify me" action that posts to `POST /v1/waitlist`.
Future<void> showCitySheet(BuildContext context, ExploreViewModel vm) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.cream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ChangeNotifierProvider.value(
      value: vm,
      child: Consumer<ExploreViewModel>(
        builder: (sheetCtx, vm, __) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _handle()),
              Text(AppLocalizations.of(sheetCtx).chooseCity,
                  style: AppText.title.copyWith(fontSize: 18)),
              const SizedBox(height: 3),
              Text(AppLocalizations.of(sheetCtx).moreCitiesComing,
                  style: AppText.small),
              const SizedBox(height: 14),
              // Live cities
              ...vm.liveCities.map((c) {
                final selected = vm.currentCity?.id == c.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      vm.selectCity(c);
                      Navigator.pop(sheetCtx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.borderLight,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          _radioDot(selected),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(c.name,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w800)),
                          ),
                          const TintBadge(text: 'LIVE'),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              // Waitlist cities
              ...vm.waitlistCities.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          _radioDot(false),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.name,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.bodyText)),
                                if (c.eta != null)
                                  Text(c.eta!,
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.faint)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showWaitlistDialog(sheetCtx, vm, c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: Text(
                                  AppLocalizations.of(sheetCtx).notifyMe,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              if (vm.liveCities.isEmpty && vm.waitlistCities.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(AppLocalizations.of(sheetCtx).noCities,
                        style: AppText.bodyMuted),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Collects a phone number and joins the city's launch waitlist.
Future<void> _showWaitlistDialog(
    BuildContext context, ExploreViewModel vm, City city) async {
  final loc = AppLocalizations.of(context);
  final controller = TextEditingController();
  final joined = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(loc.joinWaitlistTitle(city.name),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.joinWaitlistMessage(city.name),
              style: TextStyle(fontSize: 13, color: AppColors.muted)),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '+255 7XX XXX XXX',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, false),
          child: Text(loc.cancel,
              style: TextStyle(
                  color: AppColors.muted, fontWeight: FontWeight.w700)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, true),
          child: Text(loc.join,
              style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );
  if (joined == true) {
    await vm.joinWaitlist(
      city,
      phone: controller.text.trim(),
      successMessage: loc.waitlistJoined(city.name),
    );
  }
  controller.dispose();
}

/// Bottom sheet: filters (visual — server-side filtering lands with search).
Future<void> showFilterSheet(BuildContext context, ExploreViewModel vm) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.cream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetCtx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      maxChildSize: 0.78,
      minChildSize: 0.5,
      builder: (_, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
        child: Builder(builder: (innerCtx) {
          final loc = AppLocalizations.of(innerCtx);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _handle()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(loc.filters,
                      style: AppText.title.copyWith(fontSize: 18)),
                  Text(loc.reset,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted)),
                ],
              ),
              _filterGroup(loc.location, vm.filterAreas),
              _filterGroup(loc.pitchType,
                  const ['5-a-side', '7-a-side', '11-a-side', 'Futsal'],
                  firstSelected: true),
              const SizedBox(height: 16),
              Text(loc.priceRange,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              const _PriceSlider(),
              _filterGroup(loc.amenities, vm.filterAmenities),
              const SizedBox(height: 20),
              PrimaryButton(
                label: loc.showPitches,
                shadow: false,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  Navigator.pushNamed(context, Routes.results);
                },
              ),
            ],
          );
        }),
      ),
    ),
  );
}

Widget _filterGroup(String title, List<String> options,
    {bool firstSelected = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (int i = 0; i < options.length; i++)
            PillChip(
                label: options[i],
                selected: firstSelected && i == 0,
                fontSize: 12.5),
        ],
      ),
    ],
  );
}

Widget _radioDot(bool selected) => Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: selected ? AppColors.primary : AppColors.handle, width: 2),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
              ),
            )
          : null,
    );

class _PriceSlider extends StatelessWidget {
  const _PriceSlider();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
          child: LayoutBuilder(builder: (context, c) {
            final w = c.maxWidth;
            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.inputBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Positioned(
                  left: 0.12 * w,
                  right: 0.35 * w,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Positioned(left: 0.12 * w - 10, child: _thumb()),
                Positioned(left: 0.65 * w - 10, child: _thumb()),
              ],
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TSh 20,000', style: AppText.tiny),
            Text('TSh 200,000+', style: AppText.tiny),
          ],
        ),
      ],
    );
  }

  Widget _thumb() => Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2.5),
        ),
      );
}
