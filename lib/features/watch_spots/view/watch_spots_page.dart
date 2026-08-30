import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/status_views.dart';
import '../../../core/widgets/turf_image.dart';
import '../../../domain/entities/watch_spot.dart';
import '../viewmodel/watch_spots_viewmodel.dart';

class WatchSpotsPage extends StatefulWidget {
  const WatchSpotsPage({super.key});

  @override
  State<WatchSpotsPage> createState() => _WatchSpotsPageState();
}

class _WatchSpotsPageState extends State<WatchSpotsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WatchSpotsViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WatchSpotsViewModel>();

    return Container(
      color: AppColors.cream,
      child: Stack(
        children: [
          Column(
            children: [
              _Header(),
              Expanded(child: _Body(vm: vm)),
            ],
          ),
          // "List your spot" FAB
          Positioned(
            right: 20,
            bottom: 28,
            child: GestureDetector(
              onTap: () => _showListSpotSheet(context, vm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.pill),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 16, color: AppColors.lime),
                    const SizedBox(width: 7),
                    Text(
                      'List your spot',
                      style: AppText.label.copyWith(
                          color: AppColors.cream, fontSize: 13.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showListSpotSheet(
      BuildContext context, WatchSpotsViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: const _ListSpotSheet(),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cream,
      padding: const EdgeInsets.fromLTRB(
          20, AppSpacing.statusBar, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Watch Spots', style: AppText.h2),
          Text(
            'Venues showing live sport near you',
            style: AppText.small,
          ),
        ],
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.vm});
  final WatchSpotsViewModel vm;

  @override
  Widget build(BuildContext context) {
    switch (vm.state) {
      case ViewState.loading:
        return const LoadingView(label: 'Finding watch spots…');
      case ViewState.error:
        return StatusView(
          glyph: '📡',
          title: 'Could not load spots',
          message: vm.error,
          actionLabel: 'Try again',
          onAction: vm.load,
        );
      case ViewState.ready:
        if (vm.spots.isEmpty) {
          return StatusView(
            glyph: '📺',
            title: 'No watch spots yet',
            message:
                'Be the first to list a venue in your area.',
            actionLabel: null,
            onAction: null,
          );
        }
        return _SpotList(vm: vm);
    }
  }
}

class _SpotList extends StatelessWidget {
  const _SpotList({required this.vm});
  final WatchSpotsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: vm.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount: vm.spots.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _SpotCard(spot: vm.spots[i]),
      ),
    );
  }
}

// ─── Spot Card ────────────────────────────────────────────────────────────────

class _SpotCard extends StatelessWidget {
  const _SpotCard({required this.spot});
  final WatchSpot spot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.rCard),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo / fallback
          TurfImage(
            imageUrl: spot.photoUrl,
            gradient1: AppColors.primary,
            gradient2: AppColors.primaryGradientEnd,
            height: 130,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  _EntryBadge(entryTzs: spot.entryTzs, isFree: spot.isFree),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + screens
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        spot.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.cardTitle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ScreensBadge(screens: spot.screens),
                  ],
                ),
                const SizedBox(height: 4),
                // Area + address
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 13, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${spot.area} · ${spot.address}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.small,
                      ),
                    ),
                  ],
                ),
                if (spot.features.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _FeatureChips(features: spot.features),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryBadge extends StatelessWidget {
  const _EntryBadge({required this.entryTzs, required this.isFree});
  final int entryTzs;
  final bool isFree;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isFree ? AppColors.successBg : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.pill),
      ),
      child: Text(
        isFree ? 'Free entry' : Formatters.tsh(entryTzs),
        style: AppText.tiny.copyWith(
          fontWeight: FontWeight.w700,
          color: isFree ? AppColors.successText : AppColors.ink,
        ),
      ),
    );
  }
}

class _ScreensBadge extends StatelessWidget {
  const _ScreensBadge({required this.screens});
  final int screens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.neutralFill,
        borderRadius: BorderRadius.circular(AppSpacing.rSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tv_outlined, size: 11, color: AppColors.muted),
          const SizedBox(width: 4),
          Text(
            '$screens ${screens == 1 ? 'screen' : 'screens'}',
            style: AppText.tiny.copyWith(
                fontWeight: FontWeight.w700, color: AppColors.bodyText),
          ),
        ],
      ),
    );
  }
}

class _FeatureChips extends StatelessWidget {
  const _FeatureChips({required this.features});
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final f in features)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(AppSpacing.pill),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              f,
              style: AppText.tiny.copyWith(
                  color: AppColors.bodyText, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

// ─── List Spot Sheet ──────────────────────────────────────────────────────────

class _ListSpotSheet extends StatefulWidget {
  const _ListSpotSheet();

  @override
  State<_ListSpotSheet> createState() => _ListSpotSheetState();
}

class _ListSpotSheetState extends State<_ListSpotSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _contactNameCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _screensCtrl = TextEditingController(text: '1');
  final _entryCtrl = TextEditingController(text: '0');

  bool _freeEntry = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _areaCtrl.dispose();
    _addressCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _screensCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WatchSpotsViewModel>();

    if (vm.submitSuccess) {
      return _SuccessState(
        onDone: () => Navigator.pop(context),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.rSheet)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.handle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('List your spot', style: AppText.h3),
              Text(
                'Let fans know where to watch the game.',
                style: AppText.bodyMuted,
              ),
              const SizedBox(height: 20),
              _SheetField(
                label: 'Venue name',
                controller: _nameCtrl,
                hint: 'e.g. Lions Den Sports Bar',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                label: 'Area',
                controller: _areaCtrl,
                hint: 'e.g. Kinondoni',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                label: 'Address',
                controller: _addressCtrl,
                hint: 'Street / landmark',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                label: 'Your name',
                controller: _contactNameCtrl,
                hint: 'Contact name',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                label: 'Phone number',
                controller: _contactPhoneCtrl,
                hint: '0712 345 678',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                label: 'Number of screens',
                controller: _screensCtrl,
                hint: '1',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) return 'Enter at least 1';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Free entry toggle
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Entry fee', style: AppText.label),
                        Text('Leave free for no charge',
                            style: AppText.small),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _freeEntry = !_freeEntry),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 26,
                      padding: EdgeInsets.only(
                          left: _freeEntry ? 2 : 20, right: _freeEntry ? 20 : 2),
                      decoration: BoxDecoration(
                        color: _freeEntry
                            ? AppColors.successText
                            : AppColors.handle,
                        borderRadius: BorderRadius.circular(AppSpacing.pill),
                      ),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (!_freeEntry) ...[
                const SizedBox(height: 12),
                _SheetField(
                  label: 'Entry price (TSh)',
                  controller: _entryCtrl,
                  hint: '2000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (v) {
                    if (_freeEntry) return null;
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 0) return 'Enter a valid price';
                    return null;
                  },
                ),
              ],
              if (vm.submitError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.orangeBg,
                    borderRadius: BorderRadius.circular(AppSpacing.rMd),
                  ),
                  child: Text(
                    vm.submitError!,
                    style: AppText.small
                        .copyWith(color: AppColors.orange),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              PrimaryButton(
                label:
                    vm.submitting ? 'Submitting…' : 'Submit listing',
                enabled: !vm.submitting,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<WatchSpotsViewModel>();
    await vm.submitApplication(
      name: _nameCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      contactName: _contactNameCtrl.text.trim(),
      contactPhone: _contactPhoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      lat: 0.0,
      lng: 0.0,
      screens: int.tryParse(_screensCtrl.text) ?? 1,
      entry: _freeEntry ? 0 : (int.tryParse(_entryCtrl.text) ?? 0),
      features: [],
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppText.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.body.copyWith(color: AppColors.faint),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.rLg),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.rLg),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.rLg),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.rLg),
              borderSide:
                  const BorderSide(color: AppColors.danger, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.rLg),
              borderSide:
                  const BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.rSheet)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.successBg,
              shape: BoxShape.circle,
            ),
            child: const Text('✅',
                style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(height: 18),
          Text('Application submitted!', style: AppText.h3),
          const SizedBox(height: 6),
          Text(
            'We\'ll review your spot and get back to you within 24 hours.',
            textAlign: TextAlign.center,
            style: AppText.bodyMuted,
          ),
          const SizedBox(height: 28),
          PrimaryButton(label: 'Done', onTap: onDone),
        ],
      ),
    );
  }
}
