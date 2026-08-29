import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../viewmodel/onboarding_viewmodel.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final slide = vm.current;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          // ---- Hero image with gradient + contextual overlay ----
          Expanded(
            flex: 12,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.primary),
                Image.network(
                  'https://images.unsplash.com/photo-${slide.imageId}?w=800&q=60',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0A1E16).withValues(alpha: 0.25),
                        const Color(0xFF0A1E16).withValues(alpha: 0),
                        AppColors.cream.withValues(alpha: 0),
                        AppColors.cream,
                      ],
                      stops: const [0, 0.4, 0.75, 1],
                    ),
                  ),
                ),
                if (vm.isSecond) const _TimeChipsOverlay(),
                // if (vm.isThird) const _BookedOverlay(),
              ],
            ),
          ),
          // ---- Copy + CTA ----
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (
                        int i = 0;
                        i < OnboardingViewModel.slides.length;
                        i++
                      )
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: i == vm.index ? 22 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == vm.index
                                  ? AppColors.primary
                                  : AppColors.handle,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(slide.head, style: AppText.h1),
                  const SizedBox(height: 8),
                  Text(
                    slide.sub,
                    style: AppText.body.copyWith(color: AppColors.muted),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: vm.isLast
                        ? AppLocalizations.of(context).onbGetStarted
                        : AppLocalizations.of(context).onbNext,
                    shadow: false,
                    onTap: () {
                      if (vm.next()) {
                        Navigator.pushReplacementNamed(context, Routes.login);
                      }
                    },
                  ),
                  if (vm.isThird)
                    _TextAction(
                      AppLocalizations.of(context).onbSignIn,
                      color: AppColors.primary,
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, Routes.login),
                    ),
                  if (!vm.isLast)
                    _TextAction(
                      AppLocalizations.of(context).onbSkip,
                      color: AppColors.muted,
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, Routes.home),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction(this.label, {required this.color, this.onTap});
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeChipsOverlay extends StatelessWidget {
  const _TimeChipsOverlay();

  @override
  Widget build(BuildContext context) {
    Widget chip(String t, {bool lime = false, bool struck = false}) =>
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: lime ? AppColors.lime : AppColors.cream,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A1E16).withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            t,
            style: TextStyle(
              fontSize: 15,
              fontWeight: lime ? FontWeight.w800 : FontWeight.w700,
              decoration: struck
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: AppColors.ink.withValues(alpha: struck ? 0.55 : 1),
            ),
          ),
        );

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          chip('18:00'),
          const SizedBox(width: 10),
          chip('19:00', lime: true),
          const SizedBox(width: 10),
          chip('20:00', struck: true),
        ],
      ),
    );
  }
}

// class _BookedOverlay extends StatelessWidget {
//   const _BookedOverlay();

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
//         decoration: BoxDecoration(
//           color: AppColors.cream,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0xFF0A1E16).withValues(alpha: 0.35),
//               blurRadius: 24,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 34,
//               height: 34,
//               decoration: const BoxDecoration(
//                   color: AppColors.primary, shape: BoxShape.circle),
//               child: const Center(
//                 child: Text('✓',
//                     style: TextStyle(
//                         color: AppColors.lime,
//                         fontWeight: FontWeight.w800,
//                         fontSize: 16)),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Booked',
//                     style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
//                 Text('Tonight · 8:00 PM',
//                     style: TextStyle(fontSize: 12, color: AppColors.muted)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
