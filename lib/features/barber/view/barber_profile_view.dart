import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/avatar_premium.dart';
import 'package:core/core.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/features/profile/presentation/widgets/ob_input_field.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_details_glass_card.dart';
import 'package:trim_flow/features/profile/presentation/views/profile_settings_view.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';

class BarberProfileView extends StatelessWidget {
  const BarberProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const BarberProfileContent();
  }
}

class BarberProfileContent extends StatefulWidget {
  const BarberProfileContent({super.key});

  @override
  State<BarberProfileContent> createState() => _BarberProfileContentState();
}

class _BarberProfileContentState extends State<BarberProfileContent> {
  
  void _showEditSheet(BuildContext context, UserProfile user) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final phoneController = TextEditingController(text: user.phone);

    final profileBloc = context.read<ProfileBloc>();

    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (sheetContext) => BlocProvider.value(
        value: profileBloc,
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 40,
          ),
          child: SingleChildScrollView(
            controller: ModalScrollController.of(sheetContext),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 32),
                  Text('EDITAR PERFIL', style: TextStyle(color: context.primaryGold, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 40),
                  ObInputField(
                    label: 'Nombre',
                    controller: nameController,
                    maxLength: 15,
                    showCounter: true,
                    validator: (val) => (val == null || val.isEmpty) ? 'Campo requerido' : null,
                  ),
                  ObInputField(
                    label: 'Apellido',
                    controller: lastNameController,
                    maxLength: 10,
                    showCounter: true,
                    validator: (val) => (val == null || val.isEmpty) ? 'Campo requerido' : null,
                  ),
                  ObInputField(
                    label: 'WhatsApp',
                    controller: phoneController,
                    prefix: '+51',
                    hasPrefixDivider: true,
                    maxLength: 9,
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Campo requerido';
                      if (val.length != 9 || !RegExp(r'^\d+$').hasMatch(val)) return 'Número no válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      final isLoading = state.status == ProfileStatus.loading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : () {
                          if (formKey.currentState?.validate() ?? false) {
                            context.read<ProfileBloc>().add(SaveProfileData(
                              firstName: nameController.text,
                              lastName: lastNameController.text,
                              phone: phoneController.text,
                              birthDate: '',
                            ));
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryGold,
                          foregroundColor: context.backgroundBlack,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                          disabledForegroundColor: Colors.white10,
                        ),
                        child: isLoading
                            ? CupertinoActivityIndicator(color: context.backgroundBlack)
                            : const Text('GUARDAR CAMBIOS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
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

          final user = state.user;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline_rounded, color: Colors.white24, size: 64),
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

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(context, user),
                const SizedBox(height: 12),

                // DATOS PERSONALES (WhatsApp / Birthdate)
                ProfileDetailsGlassCard(
                  user: user,
                  onEdit: () => _showEditSheet(context, user),
                  isBarber: true,
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile user) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'images/mustache.png',
              width: 32,
              height: 32,
              color: context.primaryGold,
            ),
            const SizedBox(height: 8),
            
            // Row with Header Title & Configuration Settings Button (Perfect vertical alignment!)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'PERFIL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                GestureDetector(
                  onTap: () {
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
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: const Icon(Icons.settings_outlined, size: 22, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(width: 40, height: 3, color: context.primaryGold),
            
            const SizedBox(height: 24),
          
          // Centered Info & Avatar with modern Pencil Overlay
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatarWithEdit(context, user),
                const SizedBox(height: 20),
                Text(
                  '${user.firstName} ${user.lastName}'.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                // Barbero ID Badge relocated right below the email (centered & unified!)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.primaryGold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.primaryGold.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'BARBERO ID: ${user.barberId?.substring(0, 8) ?? user.id.substring(0, 8)}',
                    style: TextStyle(
                      color: context.primaryGold,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildAvatarWithEdit(BuildContext context, UserProfile user) {
    final displayName = '${user.firstName} ${user.lastName}'.trim();
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.primaryGold.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: AvatarPremium(
            displayName: displayName.isEmpty ? 'Barbero' : displayName,
            photoUrl: user.photoUrl,
            size: 96,
          ),
        ),
        // Modern circular floating pencil edit button overlapping the avatar
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _showEditSheet(context, user),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.primaryGold,
                shape: BoxShape.circle,
                border: Border.all(color: context.backgroundBlack, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: const Icon(Icons.edit_rounded, color: Colors.black, size: 14),
            ),
          ),
        ),
      ],
    );
  }

}
