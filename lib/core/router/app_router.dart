import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../di/injection.dart';
import '../../features/ai_assistant/view/ai_page.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/auth/viewmodel/login_viewmodel.dart';
import '../../features/booking/view/processing_page.dart';
import '../../features/booking/view/scan_pay_page.dart';
import '../../features/booking/view/success_page.dart';
import '../../features/booking/view/summary_page.dart';
import '../../features/explore/view/results_page.dart';
import '../../features/explore/viewmodel/results_viewmodel.dart';
import '../../features/onboarding/view/onboarding_page.dart';
import '../../features/onboarding/view/splash_page.dart';
import '../../features/onboarding/viewmodel/onboarding_viewmodel.dart';
import '../../features/pitch_detail/view/detail_page.dart';
import '../../features/pitch_detail/viewmodel/detail_viewmodel.dart';
import '../../features/shell/view/main_shell.dart';
import 'route_names.dart';

/// Central route table. Each screen is wired to its ViewModel here so views stay
/// free of construction logic.
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _fade(const SplashPage());

      case Routes.onboarding:
        return _slide(ChangeNotifierProvider(
          create: (_) => getIt<OnboardingViewModel>(),
          child: const OnboardingPage(),
        ));

      case Routes.login:
        return _slide(ChangeNotifierProvider(
          create: (_) => getIt<LoginViewModel>(),
          child: const LoginPage(),
        ));

      case Routes.home:
        return _fade(const MainShell());

      case Routes.results:
        return _slide(ChangeNotifierProvider(
          create: (_) => getIt<ResultsViewModel>()..load(),
          child: const ResultsPage(),
        ));

      case Routes.detail:
        final pitchId = settings.arguments as String? ?? '';
        return _slide(ChangeNotifierProvider(
          create: (_) => getIt<DetailViewModel>()..load(pitchId),
          child: const DetailPage(),
        ));

      case Routes.summary:
        return _slide(const SummaryPage());

      case Routes.processing:
        return _fade(const ProcessingPage());

      case Routes.success:
        return _fade(const SuccessPage());

      case Routes.scanPay:
        return _slide(const ScanPayPage());

      case Routes.ai:
        return _slide(const AiPage());

      default:
        return _fade(const SplashPage());
    }
  }

  static PageRoute _fade(Widget child) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => child,
        transitionsBuilder: (_, anim, __, c) =>
            FadeTransition(opacity: anim, child: c),
      );

  static PageRoute _slide(Widget child) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) => child,
        transitionsBuilder: (_, anim, __, c) {
          final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(position: anim.drive(tween), child: c);
        },
      );
}
