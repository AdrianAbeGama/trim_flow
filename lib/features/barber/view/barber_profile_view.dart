import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/domain/repositories/agenda_repository.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_data.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_edit_sheet.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_header.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_more.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_primitives.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_stats.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_today_agenda.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/features/profile/presentation/views/profile_settings_view.dart';

/// BarberProfileView — perfil del barbero: identidad + resumen real de hoy +
/// datos personales + logout. La agenda (citas, historial) vive en su pestaña,
/// no se repite aqui.
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
  Future<AgendaTodaySummary>? _summaryFuture;
  Future<List<AgendaAppointment>>? _agendaFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final barberId = Supabase.instance.client.auth.currentUser?.id;
    if (barberId != null) {
      final repo = getIt<AgendaRepository>();
      _summaryFuture = repo.fetchTodaySummary(barberId: barberId);
      _agendaFuture =
          repo.fetchAgendaForDay(barberId: barberId, day: DateTime.now());
    }
  }

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
    if (mounted) setState(_loadData);
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  String _nextLabel(DateTime? next) {
    if (next == null) return '—';
    return '${next.hour.toString().padLeft(2, '0')}:${next.minute.toString().padLeft(2, '0')}';
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
                SliverToBoxAdapter(
                  child: FutureBuilder<AgendaTodaySummary>(
                    future: _summaryFuture,
                    builder: (context, snap) {
                      final s = snap.data;
                      return BarberProfileStatsRow(
                        cutsToday: s?.completedCuts ?? 0,
                        revenueToday: s?.revenue ?? 0,
                        nextLabel: _nextLabel(s?.nextStart),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: FutureBuilder<List<AgendaAppointment>>(
                    future: _agendaFuture,
                    builder: (context, snap) {
                      return BarberProfileTodayAgenda(
                        appointments: snap.data ?? const [],
                        loading: snap.connectionState == ConnectionState.waiting,
                      );
                    },
                  ),
                ),
                BarberProfilePersonalData(
                  user: user,
                  onTap: () => _editProfile(user),
                  branchName: state.branchName,
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
