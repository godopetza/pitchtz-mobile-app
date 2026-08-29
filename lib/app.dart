import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/config/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/router/route_names.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/toast_controller.dart';
import 'di/injection.dart';
import 'features/booking/viewmodel/booking_flow_viewmodel.dart';
import 'l10n/gen/app_localizations.dart';

class PitchTzApp extends StatelessWidget {
  const PitchTzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Shared booking flow (detail → summary → processing → success).
        ChangeNotifierProvider.value(value: getIt<BookingFlowViewModel>()),
        ChangeNotifierProvider.value(value: getIt<ToastController>()),
        // App locale — switching in Profile re-renders the whole app.
        ChangeNotifierProvider.value(value: getIt<LocaleController>()),
      ],
      child: Consumer<LocaleController>(
        builder: (context, localeCtrl, _) => MaterialApp(
          title: 'Pitch TZ',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: localeCtrl.locale,
          supportedLocales: LocaleController.supported,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: Routes.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
          builder: (context, child) => _ToastOverlay(child: child),
        ),
      ),
    );
  }
}

/// Renders the app-wide toast above the whole navigator.
class _ToastOverlay extends StatelessWidget {
  const _ToastOverlay({required this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null) child!,
        Consumer<ToastController>(
          builder: (context, toast, _) {
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              left: 20,
              right: 20,
              bottom: toast.isVisible ? 110 : -80,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: toast.isVisible ? 1 : 0,
                child: IgnorePointer(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.backdrop.withValues(alpha: 0.35),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Text(
                        toast.message ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.cream,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
