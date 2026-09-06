import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/locale_controller.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/toast_controller.dart';
import '../../../di/injection.dart';
import '../../../domain/entities/api_booking.dart';
import '../../../features/shell/viewmodel/shell_viewmodel.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../viewmodel/profile_viewmodel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().load();
    });
  }

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
          // ---- Header card ----
          _HeaderCard(vm: vm, loc: loc),
          const SizedBox(height: 12),

          // ---- Stats (signed-in only) ----
          if (vm.isSignedIn) ...[
            _StatsRow(vm: vm),
            const SizedBox(height: 12),
          ],

          // ---- Recent bookings preview ----
          if (vm.isSignedIn && vm.bookings.isNotEmpty) ...[
            _RecentBookings(vm: vm),
            const SizedBox(height: 12),
          ],

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

          // ---- Language toggle ----
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
    if (confirmed == true && context.mounted) {
      await vm.signOut();
      getIt<ToastController>().show(loc.loggedOutToast);
    }
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
              : const Border(
                  bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
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

// ---------------------------------------------------------------------------
// Header card
// ---------------------------------------------------------------------------

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.vm, required this.loc});
  final ProfileViewModel vm;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _Avatar(vm: vm),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.isSignedIn ? vm.user!.name : loc.guestName,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cream),
                ),
                const SizedBox(height: 2),
                Text(
                  vm.isSignedIn ? vm.user!.email : loc.guestSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.cream.withValues(alpha: 0.7)),
                ),
                if (vm.isSignedIn) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.lime.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('PitchTZ Member',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lime)),
                  ),
                ],
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
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(loc.signIn,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ),
            ),
          if (vm.isLoading)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.lime),
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.vm});
  final ProfileViewModel vm;

  @override
  Widget build(BuildContext context) {
    final url = vm.isSignedIn ? vm.user!.avatarUrl : null;
    final fallback = Text(
      vm.isSignedIn ? vm.user!.initials : '?',
      style: const TextStyle(
          color: AppColors.lime, fontWeight: FontWeight.w800, fontSize: 20),
    );
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.lime.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.lime, width: 2),
      ),
      child: url == null || url.isEmpty
          ? fallback
          : Image.network(url,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats row
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.vm});
  final ProfileViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatCard(
                value: vm.totalBookings.toString(),
                label: 'Total Bookings')),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
                value: vm.completedBookings.toString(),
                label: 'Completed')),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
                value: vm.upcomingBookings.toString(),
                label: 'Upcoming')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent bookings preview
// ---------------------------------------------------------------------------

class _RecentBookings extends StatelessWidget {
  const _RecentBookings({required this.vm});
  final ProfileViewModel vm;

  @override
  Widget build(BuildContext context) {
    final recent = vm.bookings.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Bookings',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            GestureDetector(
              onTap: () => getIt<ShellViewModel>().setIndex(1),
              child: Text('See all',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              for (int i = 0; i < recent.length; i++)
                _BookingRow(
                  booking: recent[i],
                  last: i == recent.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.booking, required this.last});
  final ApiBooking booking;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(booking.status);
    final label = _statusLabel(booking.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.code,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 1),
                Text(
                  Formatters.dateTime(booking.startsAt),
                  style: TextStyle(
                      fontSize: 11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.tsh(booking.totalTzs),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.primary;
      case 'completed':
        return const Color(0xFF16A34A);
      case 'part_paid':
        return const Color(0xFFD97706);
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.muted;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'part_paid':
        return 'Part Paid';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }
}
