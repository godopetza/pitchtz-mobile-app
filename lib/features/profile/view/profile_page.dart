import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/locale_controller.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/toast_controller.dart';
import '../../../di/injection.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../viewmodel/profile_viewmodel.dart';

/// Profile: session card (sign in / log out), settings rows, and the language
/// toggle that switches the whole app between English and Kiswahili.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final localeCtrl = context.watch<LocaleController>();
    final loc = AppLocalizations.of(context);

    return Container(
      color: AppColors.cream,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 62, 20, 24),
        children: [
          // ---- Header: signed-in user or guest ----
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                _avatar(vm),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vm.isSignedIn ? vm.user!.name : loc.guestName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      Text(
                        vm.isSignedIn ? vm.user!.email : loc.guestSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                if (!vm.isSignedIn)
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, Routes.login),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(loc.signIn,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cream)),
                    ),
                  ),
              ],
            ),
          ),
          // ---- Settings rows ----
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: _card(),
            child: Column(
              children: [
                _row(loc.rowAccount, ''),
                _row(loc.rowPayments, 'M-Pesa'),
                _row(loc.rowNotifications, loc.onLabel),
                _row(loc.rowFavoriteAreas, 'Mikocheni'),
                _row(loc.rowHelp, ''),
                _row(loc.rowTerms, '', last: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ---- Language toggle (drives real localization) ----
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: _card(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc.language,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.neutralFill,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      _lang(context, localeCtrl, 'English', 'en',
                          selected: !localeCtrl.isSwahili),
                      _lang(context, localeCtrl, 'Kiswahili', 'sw',
                          selected: localeCtrl.isSwahili),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ---- Log out ----
          if (vm.isSignedIn) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _confirmLogout(context, vm, loc),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(loc.logOut,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.danger)),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Center(
            child: Text(loc.versionLabel,
                style: TextStyle(fontSize: 12, color: AppColors.faint)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(
      BuildContext context, ProfileViewModel vm, AppLocalizations loc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(loc.logOutConfirmTitle,
            style:
                const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        content: Text(loc.logOutConfirmMessage,
            style: TextStyle(fontSize: 13.5, color: AppColors.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(loc.cancel,
                style: TextStyle(
                    color: AppColors.muted, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(loc.logOut,
                style: TextStyle(
                    color: AppColors.danger, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await vm.signOut();
      getIt<ToastController>().show(loc.loggedOutToast);
    }
  }

  /// Google/Apple picture when the account has one, initials otherwise.
  Widget _avatar(ProfileViewModel vm) {
    final url = vm.isSignedIn ? vm.user!.avatarUrl : null;
    final fallback = Text(
      vm.isSignedIn ? vm.user!.initials : '👤',
      style: TextStyle(
          color: AppColors.lime, fontWeight: FontWeight.w800, fontSize: 19),
    );
    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
          color: AppColors.primary, shape: BoxShape.circle),
      child: url == null || url.isEmpty
          ? fallback
          : Image.network(url,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback),
    );
  }

  BoxDecoration _card() => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      );

  Widget _row(String k, String v, {bool last = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(v.isEmpty ? '›' : '$v ›',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted)),
          ],
        ),
      );

  Widget _lang(BuildContext context, LocaleController ctrl, String label,
      String code,
      {required bool selected}) {
    return GestureDetector(
      onTap: () => ctrl.setLocale(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.cream : AppColors.muted)),
      ),
    );
  }
}
