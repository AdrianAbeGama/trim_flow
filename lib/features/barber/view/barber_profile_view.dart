import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_client_sheet.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_clients.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_data.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_edit_sheet.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_header.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_history.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_more.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_history_sheet.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_primitives.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_stats.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/features/profile/presentation/views/profile_settings_view.dart';

/// BarberProfileView — orquestador limpio.
/// Toda la UI vive en widgets/. Este archivo es solo el state + composición.
class BarberProfileView extends StatelessWidget {
  const BarberProfileView({super.key});

  @override
  Widget build(BuildContext context) => const _BarberProfileBody();
}

class _BarberProfileBody extends StatefulWidget {
  const _BarberProfileBody();

  @override
  State<_BarberProfileBody> createState() => _BarberProfileBodyState();
}

class _BarberProfileBodyState extends State<_BarberProfileBody> {
  // === MOCK DATA (mientras no hay backend) ===
  static const int _mockCutsToday = 5;
  static const int _mockCutsWeek = 24;
  static const double _mockRevenueToday = 175.0;

  static final List<BarberClientItem> _mockNextClients = [
    const BarberClientItem(
      time: '15:00',
      name: 'Luis Pérez',
      service: 'Corte + Barba',
      dateLabel: 'HOY',
    ),
    const BarberClientItem(
      time: '16:30',
      name: 'Carlos Ruiz',
      service: 'Corte Clásico',
      dateLabel: 'HOY',
    ),
    const BarberClientItem(
      time: '10:00',
      name: 'Miguel Soto',
      service: 'Barba Premium',
      dateLabel: 'MAÑ',
    ),
  ];

  static final List<BarberHistoryItem> _mockHistory = [
    const BarberHistoryItem(
      service: 'Corte Clásico',
      client: 'José Castro',
      dateStr: 'Hoy · 10:30',
      price: 35,
      isCompleted: true,
    ),
    const BarberHistoryItem(
      service: 'Corte + Barba',
      client: 'Pedro Vega',
      dateStr: 'Hoy · 09:00',
      price: 65,
      isCompleted: true,
    ),
    const BarberHistoryItem(
      service: 'Barba Premium',
      client: 'Ana López',
      dateStr: 'Ayer · 18:00',
      price: 0,
      isCompleted: false,
    ),
    const BarberHistoryItem(
      service: 'Corte Clásico',
      client: 'Juan Díaz',
      dateStr: 'Ayer · 16:30',
      price: 35,
      isCompleted: true,
    ),
  ];

  // === ACTIONS ===

  void _editProfile(UserProfile user) {
    HapticFeedback.lightImpact();
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E0E0E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BarberProfileEditSheet(user: user),
    );
  }

  void _openSettings(UserProfile user) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ProfileBloc>()),
            BlocProvider.value(value: context.read<AppModeBloc>()),
          ],
          child: ProfileSettingsView(user: user, isBarber: true),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    HapticFeedback.mediumImpact();
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir de tu cuenta?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<AppModeBloc>().add(const AppModeEvent.requestLogout());
    }
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    context.read<ProfileBloc>().add(const ProfileEvent.load());
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return Center(
              child: CupertinoActivityIndicator(
                color: context.primaryGold, radius: 14),
            );
          }
          final user = state.user;
          if (user == null) {
            return BarberErrorView(
              gold: context.primaryGold,
              onRetry: () =>
                  context.read<ProfileBloc>().add(const ProfileEvent.load()),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: context.primaryGold,
            backgroundColor: const Color(0xFF0E0E0E),
            displacement: 60,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                BarberProfileHeader(
                  user: user,
                  onAvatarTap: () => _editProfile(user),
                  onSettingsTap: () => _openSettings(user),
                ),
                BarberProfileNextClient(
                  client: _mockNextClients.first,
                  onTap: () => BarberClientDetailSheet.show(
                    context,
                    _mockNextClients.first,
                  ),
                ),
                BarberProfileStatsRow(
                  cutsToday: _mockCutsToday,
                  cutsWeek: _mockCutsWeek,
                  revenueToday: _mockRevenueToday,
                ),
                BarberProfileScheduledList(
                  clients: _mockNextClients.sublist(1),
                ),
                BarberProfileHistory(
                  history: _mockHistory,
                  onSeeAll: () =>
                      BarberProfileFullHistorySheet.show(context, _mockHistory),
                ),
                BarberProfilePersonalData(
                  user: user,
                  onTap: () => _editProfile(user),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: BarberProfileLogoutButton(onTap: _confirmLogout),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }
}
