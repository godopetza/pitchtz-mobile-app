import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/toast_controller.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/map_backdrop.dart';
import '../../../core/widgets/status_views.dart';
import '../../../core/widgets/turf_image.dart';
import '../../../di/injection.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../viewmodel/results_viewmodel.dart';
import '../widgets/pitch_cards.dart';
import 'explore_map_view.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ResultsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Padding(
        padding: const EdgeInsets.only(top: 62),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  CircleIconButton(
                    border: AppColors.border,
                    onTap: () => Navigator.pop(context),
                    child: const Text('‹', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text('Dar es Salaam',
                          style: TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _viewToggle(context, vm),
                ],
              ),
            ),
            if (vm.state == ResultsState.ready && !vm.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      AppLocalizations.of(context)
                          .nPitchesAvailable(vm.resultCount),
                      style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            Expanded(child: _body(context, vm)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ResultsViewModel vm) {
    final loc = AppLocalizations.of(context);
    switch (vm.state) {
      case ResultsState.loading:
        return const LoadingView();
      case ResultsState.error:
        return StatusView(
          glyph: '📡',
          title: loc.errLoadPitches,
          message: vm.error,
          actionLabel: loc.tryAgain,
          onAction: vm.load,
        );
      case ResultsState.ready:
        if (vm.isEmpty) {
          return StatusView(
            glyph: '⚽',
            title: loc.emptyResultsTitle,
            message: loc.emptyResultsMessage,
            actionLabel: loc.refresh,
            onAction: vm.load,
          );
        }
        return vm.view == ResultsView.list
            ? _list(context, vm)
            : _map(context, vm);
    }
  }

  Widget _viewToggle(BuildContext context, ResultsViewModel vm) {
    final loc = AppLocalizations.of(context);
    Widget seg(String label, bool selected, VoidCallback onTap) =>
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? AppColors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.ink : AppColors.muted)),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.neutralFill,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          seg(loc.listLabel, vm.view == ResultsView.list, vm.setList),
          seg(loc.mapLabel, vm.view == ResultsView.map, vm.setMap),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, ResultsViewModel vm) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: vm.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        itemCount: vm.venues.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final p = vm.venues[i];
          return ResultCard(
            pitch: p,
            onTap: () =>
                Navigator.pushNamed(context, Routes.detail, arguments: p.id),
            onToggleFav: () => getIt<ToastController>().show(
                AppLocalizations.of(context).favoritesComingSoonToast),
          );
        },
      ),
    );
  }

  Widget _map(BuildContext context, ResultsViewModel vm) {
    final projection = MapProjection(vm.venues);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Stack(
        children: [
          Positioned.fill(
            child: MapBackdrop(
              overlayBuilder: (size) => Stack(
                children: [
                  for (int i = 0; i < vm.venues.length; i++)
                    Builder(builder: (_) {
                      final p = vm.venues[i];
                      final (fx, fy) =
                          projection.project(p, i, vm.venues.length);
                      return Positioned(
                        left: fx * size.width,
                        top: fy * size.height,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, -1),
                          child: MapPin(
                            label: Formatters.priceK(p.pricePerHour),
                            selected: vm.mapSel == p.id,
                            onTap: () => vm.selectPin(p.id),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          if (vm.hasMapSel)
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: _selectedCard(context, vm),
            ),
        ],
      ),
    );
  }

  Widget _selectedCard(BuildContext context, ResultsViewModel vm) {
    final p = vm.mapSelPitch!;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, Routes.detail, arguments: p.id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            TurfImage(
              imageUrl: p.imageUrl,
              gradient1: Color(p.gradient1),
              gradient2: Color(p.gradient2),
              width: 78,
              height: 74,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('${p.area} · ★ ${p.ratingLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(height: 4),
                  Text('${Formatters.tsh(p.pricePerHour)}/hr',
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
