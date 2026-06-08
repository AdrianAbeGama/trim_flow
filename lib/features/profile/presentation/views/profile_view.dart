
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_bloc.dart';
import 'package:trim_flow/features/products/presentation/views/orders_view.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/features/profile/presentation/views/profile_settings_view.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_header.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_fidelity.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_next_appointment.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_data_settings.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_coupons_section.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_history.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_primitives.dart';

import '../widgets/profile_edit_sheet.dart';
import '../widgets/profile_ticket_modal.dart';

/// Profile cliente — iOS premium estilo Apple Fitness/Wallet/Music.
///
/// **Carácter visual:**
/// - Header con avatar + greeting + settings gear
/// - HERO: anillo de fidelidad animado custom-painted (estilo Activity Rings)
/// - Hero card de próxima cita con gradiente dorado y pulse
/// - Quick stats row (3 cards horizontales)
/// - Carousel de citas programadas (scroll horizontal)
/// - Timeline de historial con status dots y precios
/// - Datos personales en cards con iconos
/// - Settings shortcuts agrupados
/// - Logout destructive prominente
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) => const _ProfileBody();
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody();

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileBloc>().add(const ProfileEvent.clearBadge());
      }
    });
  }

  // ============= ACTIONS =============

  void _editProfile(UserProfile user) {
    HapticFeedback.lightImpact();
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E0E0E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ProfileEditSheet(
        user: user,
        profileBloc: context.read<ProfileBloc>(),
      ),
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
          child: ProfileSettingsView(user: user, isBarber: false),
        ),
      ),
    );
  }

  void _openTicket(Reservation r) {
    HapticFeedback.lightImpact();
    ProfileTicketModal.show(context, r);
  }

  void _openOrders() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<OrdersBloc>(),
          child: const OrdersView(),
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

  // ============= BUILD =============

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return ProfileLoadingState(gold: context.primaryGold);
          }
          final user = state.user;
          if (user == null) {
            return ProfileErrorState(
              gold: context.primaryGold,
              onRetry: () =>
                  context.read<ProfileBloc>().add(const ProfileEvent.load()),
            );
          }

          final next = state.scheduledAppointments.isNotEmpty
              ? state.scheduledAppointments.first
              : null;

          final orders = context.watch<OrdersBloc>().state.orders;
          final hasActiveOrders = orders.any((o) =>
              o.status == OrderStatus.pendingPayment ||
              o.status == OrderStatus.paid ||
              o.status == OrderStatus.ready);

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
                // 1. HEADER
                ProfileViewHeader(
                  user: user,
                  onAvatarTap: () => _editProfile(user),
                  onSettingsTap: () => _openSettings(user),
                  onOrdersTap: _openOrders,
                  hasActiveOrders: hasActiveOrders,
                  clientCode: state.clientCode,
                ),

                // 2. FIDELITY RING (hero element animado)
                ProfileFidelityHero(
                  completed: state.completedCuts,
                  isRewardAvailable: state.isRewardAvailable,
                  onClaim: () =>
                      context.read<ProfileBloc>().add(const ClaimReward()),
                ),

                // 3. PRÓXIMA CITA (hero card)
                if (next != null)
                  ProfileNextAppointmentHero(
                    appointment: next,
                    onTap: () => _openTicket(next),
                  ),

                // 4. MIS CUPONES (reales del cliente)
                ProfileCouponsSection(coupons: state.coupons),

                // 5. HISTORIAL TIMELINE — siempre visible (con empty state)
                ProfileHistoryTimeline(history: state.appointmentHistory),

                // 7. DATOS PERSONALES
                ProfilePersonalDataGrid(
                  user: user,
                  onTap: () => _editProfile(user),
                  lastVisit: state.lastVisit,
                ),

                // 8. LOGOUT
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: ProfileLogoutButton(onTap: _confirmLogout),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// 1. HEADER — Avatar + Greeting + Settings
// ============================================================================

