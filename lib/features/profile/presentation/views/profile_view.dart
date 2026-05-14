import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:core/core.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_loyalty_card.dart';
import '../widgets/profile_history_card.dart';
import '../widgets/profile_notifications_section.dart';
import '../widgets/profile_detail_item.dart';
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
  bool _isHistoryExpanded = false;

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
                const SizedBox(height: 24),
                ProfileHeader(
                  user: user,
                  onEdit: () => _showEditSheet(context, user),
                ),
                const SizedBox(height: 40),

                _buildSection(context, 'NOTIFICACIONES', [
                  ProfileNotificationsSection(user: user),
                ]),

                const SizedBox(height: 32),

                _buildSection(context, 'DATOS PERSONALES', [
                  ProfileDetailItem(
                    label: 'Número de WhatsApp', 
                    value: user.phone.isEmpty ? 'Pendiente' : '+51 ${user.phone}', 
                    icon: FontAwesomeIcons.whatsapp,
                    onTap: () => _showEditSheet(context, user),
                  ),
                  ProfileDetailItem(
                    label: 'Fecha de Nacimiento', 
                    value: user.birthDate.isEmpty ? 'Pendiente' : user.birthDate, 
                    icon: FontAwesomeIcons.calendarDays,
                    onTap: () => _showEditSheet(context, user),
                  ),
                ]),

                const SizedBox(height: 32),
                ProfileLoyaltyCard(
                  completedCuts: state.completedCuts,
                  isRewardAvailable: state.isRewardAvailable,
                  isExpanded: _isLoyaltyExpanded,
                  onTap: () => setState(() => _isLoyaltyExpanded = !_isLoyaltyExpanded),
                  onClaimReward: () => context.read<ProfileBloc>().add(const ClaimReward()),
                ),

                const SizedBox(height: 20),
                ProfileHistoryCard(
                  history: user.history,
                  isExpanded: _isHistoryExpanded,
                  onTap: () => setState(() => _isHistoryExpanded = !_isHistoryExpanded),
                ),

                const SizedBox(height: 48),
                _buildLogout(context),
                const SizedBox(height: 120),
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

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(color: context.primaryGold.withValues(alpha: 0.5), fontSize: 10, letterSpacing: 1.5),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildLogout(BuildContext context) {
    return TextButton(
      onPressed: () => context.read<AppModeBloc>().add(const AppModeEvent.requestLogout()),
      child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontSize: 15)),
    );
  }
}
