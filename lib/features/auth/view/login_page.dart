import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/toast_controller.dart';
import '../../../core/widgets/buttons.dart';
import '../../../di/injection.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../viewmodel/login_viewmodel.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _goHome(BuildContext context) =>
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (_) => false);

  Future<void> _finish(
      BuildContext context, Future<UserProfile> action, String Function(UserProfile) toast) async {
    final user = await action;
    getIt<ToastController>().show(toast(user));
    if (context.mounted) _goHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 76, 26, 40),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 116),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(loc.loginTitle, style: AppText.h2.copyWith(height: 1.15)),
              const SizedBox(height: 8),
              Text(loc.loginSubtitle,
                  style: TextStyle(fontSize: 14, color: AppColors.muted)),
              const SizedBox(height: 28),
              Text(loc.phoneNumberLabel,
                  style: AppText.overline.copyWith(color: AppColors.muted)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _boxed(const Text('🇹🇿 +255',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: TextField(
                        onChanged: vm.setPhone,
                        enabled: !vm.isCodeStep,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
                        ],
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: loc.phoneHint,
                          hintStyle: TextStyle(
                              fontSize: 14, color: AppColors.faint),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (vm.isCodeStep) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (int i = 0; i < vm.digits.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.primary, width: 1.5),
                          ),
                          child: Text(vm.digits[i],
                              style: const TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 14),
              PrimaryButton(
                label: vm.busy
                    ? loc.pleaseWait
                    : vm.isCodeStep
                        ? loc.verifyAndContinue
                        : loc.sendCode,
                shadow: false,
                fontSize: 15,
                onTap: vm.busy
                    ? null
                    : () async {
                        if (!vm.isCodeStep) {
                          final ok = await vm.sendCode();
                          if (!ok) {
                            getIt<ToastController>().show(loc.enterPhoneFirst);
                          }
                        } else {
                          await _finish(context, vm.verify(),
                              (u) => loc.signedInToast(u.name));
                        }
                      },
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.inputBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(loc.orContinueWith,
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.faint)),
                  ),
                  const Expanded(child: Divider(color: AppColors.inputBorder)),
                ],
              ),
              const SizedBox(height: 22),
              OutlineButton(
                onTap: vm.busy
                    ? null
                    : () => _finish(context, vm.signInWithGoogle(),
                        (_) => loc.signedInGoogle),
                child: Text(loc.continueWithGoogle,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 9),
              OutlineButton(
                background: AppColors.ink,
                border: AppColors.ink,
                onTap: vm.busy
                    ? null
                    : () => _finish(context, vm.signInWithApple(),
                        (_) => loc.signedInApple),
                child: Text(loc.continueWithApple,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(loc.demoAuthNote,
                    textAlign: TextAlign.center, style: AppText.tiny),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => _goHome(context),
                  child: Text(loc.skipBrowse,
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _boxed(Widget child) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: child,
      );
}
