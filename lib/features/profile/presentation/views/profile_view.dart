import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:core/core.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_loyalty_card.dart';
import '../widgets/profile_active_appointments_card.dart';
import '../widgets/profile_history_card.dart';
import '../widgets/profile_details_glass_card.dart';
import '../widgets/profile_edit_sheet.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileContent();
  }
}

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  bool _isLoyaltyExpanded = false;
  bool _isActiveAppointmentsExpanded = false;
  bool _isHistoryExpanded = false;

  @override
  void initState() {
    super.initState();
    // Limpiar el badge dinámico del dock flotante al ingresar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileBloc>().add(const ProfileEvent.clearBadge());
      }
    });
  }

  void _showEditSheet(BuildContext context, UserProfile user) {
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => ProfileEditSheet(
        user: user,
        profileBloc: context.read<ProfileBloc>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundBlack,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return _buildLoading(context);
          }

          final user = state.user;
          if (user == null) {
            return _buildError(context);
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                ProfileHeader(
                  user: user,
                  onEdit: () => _showEditSheet(context, user),
                ),
                const SizedBox(height: 12),

                // 1. DATOS PERSONALES (WhatsApp / Birthdate) using custom Glassmorphic Card
                ProfileDetailsGlassCard(
                  user: user,
                  onEdit: () => _showEditSheet(context, user),
                  isBarber: false,
                ),

                const SizedBox(height: 12),

                // 2. CITAS PROGRAMADAS (Active reservations)
                ProfileActiveAppointmentsCard(
                  appointments: state.scheduledAppointments,
                  isExpanded: _isActiveAppointmentsExpanded,
                  onTap: () => setState(() => _isActiveAppointmentsExpanded = !_isActiveAppointmentsExpanded),
                ),

                const SizedBox(height: 12),

                // 3. CARTILLA DE FIDELIZACIÓN (Gamification)
                ProfileLoyaltyCard(
                  completedCuts: state.completedCuts,
                  isRewardAvailable: state.isRewardAvailable,
                  isExpanded: _isLoyaltyExpanded,
                  onTap: () => setState(() => _isLoyaltyExpanded = !_isLoyaltyExpanded),
                  onClaimReward: () => context.read<ProfileBloc>().add(const ClaimReward()),
                ),

                const SizedBox(height: 12),

                // 4. HISTORIAL DE CORTES (Historical logs)
                ProfileHistoryCard(
                  history: state.appointmentHistory,
                  isExpanded: _isHistoryExpanded,
                  onTap: () => setState(() => _isHistoryExpanded = !_isHistoryExpanded),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(color: context.primaryGold, radius: 15),
          const SizedBox(height: 16),
          Text(
            'CARGANDO PERFIL...',
            style: TextStyle(color: context.primaryGold, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline_rounded, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          const Text(
            'No se encontró información del perfil',
            style: TextStyle(color: Colors.white38),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<ProfileBloc>().add(const LoadProfileEvent()),
            style: ElevatedButton.styleFrom(backgroundColor: context.primaryGold),
            child: const Text('REINTENTAR', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
