import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/toast_controller.dart';
import '../../../core/widgets/buttons.dart';
import '../../../di/injection.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../viewmodel/login_viewmodel.dart';
import 'oauth_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    // Returning users: restore the Google account already signed in on this
    // device and open a session without any typing. Quietly does nothing
    // when there is no restorable account.
    WidgetsBinding.instance.addPostFrameCallback((_) => _trySilentSignIn());
  }

  Future<void> _trySilentSignIn() async {
    if (!mounted) return;
    final vm = context.read<LoginViewModel>();
    final loc = AppLocalizations.of(context);
    final user = await vm.trySilentSignIn();
    if (user == null || !mounted) return;
    getIt<ToastController>().show(loc.signedInToast(user.name));
    _goHome(context);
  }

  void _goHome(BuildContext context) =>
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (_) => false);

  /// Runs [action]; on success toasts karibu + lands Home, on API failure
  /// toasts the server's message and stays put.
  Future<void> _finish(BuildContext context, Future<dynamic> action) async {
    final loc = AppLocalizations.of(context);
    try {
      final user = await action;
      getIt<ToastController>().show(loc.signedInToast(user.name));
      if (context.mounted) _goHome(context);
    } on ApiException catch (e) {
      getIt<ToastController>().show(e.userMessage);
    }
  }

  Future<void> _oauth(
      BuildContext context, LoginViewModel vm, String provider) async {
    final loc = AppLocalizations.of(context);
    if (kIsWeb) {
      // The WebView interception only exists in the mobile builds.
      getIt<ToastController>().show(loc.socialSignInMobileOnly);
      return;
    }

    // 1 — Native first: the device's Google account picker / Apple Face ID
    //     sheet, so users pick an account already on the phone.
    try {
      final native = await vm.signInWithProvider(provider);
      switch (native.status) {
        case NativeSignInStatus.success:
          getIt<ToastController>().show(loc.signedInToast(native.user!.name));
          if (context.mounted) _goHome(context);
          return;
        case NativeSignInStatus.cancelled:
          return; // user dismissed the sheet — stay put, no fallback
        case NativeSignInStatus.unavailable:
          break; // fall through to the browser redirect flow
      }
    } on ApiException catch (e) {
      getIt<ToastController>().show(e.userMessage);
      return;
    }

    // 2 — Fallback: the `/auth/{provider}/start` redirect flow in a WebView.
    if (!context.mounted) return;
    final token = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => OAuthPage(provider: provider)),
    );
    if (!context.mounted) return;
    if (token == null) return; // closed the sheet or the provider errored
    await _finish(context, vm.adoptToken(token));
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
              Text(loc.emailLabel,
                  style: AppText.overline.copyWith(color: AppColors.muted)),
              const SizedBox(height: 8),
              _field(
                child: TextField(
                  onChanged: vm.setEmail,
                  enabled: !vm.isCodeStep,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: _input(loc.emailHint),
                ),
              ),
              if (vm.isCodeStep) ...[
                const SizedBox(height: 14),
                Text(loc.codeSentTo(vm.email),
                    style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
                const SizedBox(height: 10),
                _field(
                  child: TextField(
                    onChanged: vm.setCode,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 12),
                    decoration: _input('••••••').copyWith(counterText: ''),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: GestureDetector(
                    onTap: vm.busy ? null : vm.changeEmail,
                    child: Text(loc.changeEmail,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ),
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
                          if (!vm.emailLooksValid) {
                            getIt<ToastController>().show(loc.enterEmailFirst);
                            return;
                          }
                          try {
                            await vm.sendCode();
                          } on ApiException catch (e) {
                            getIt<ToastController>().show(e.userMessage);
                          }
                        } else {
                          if (!vm.codeComplete) return;
                          await _finish(context, vm.verify());
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
                onTap: vm.busy ? null : () => _oauth(context, vm, 'google'),
                child: Text(loc.continueWithGoogle,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 9),
              OutlineButton(
                background: AppColors.ink,
                border: AppColors.ink,
                onTap: vm.busy ? null : () => _oauth(context, vm, 'apple'),
                child: Text(loc.continueWithApple,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
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

  Widget _field({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: child,
      );

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: AppColors.faint),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.all(14),
      );
}
