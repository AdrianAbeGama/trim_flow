import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/utils/date_input_formatter.dart';
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
    final birthDateController = TextEditingController(text: user.birthDate);
    
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
                  ObInputField(
                    label: 'Fecha de Nacimiento',
                    controller: birthDateController,
                    hintText: 'DD / MM / AAAA',
                    keyboardType: TextInputType.number,
                    inputFormatters: [DateInputFormatter()],
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Campo requerido';
                      if (!_isValidDate(val)) return 'Fecha no válida';
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
                              birthDate: birthDateController.text,
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

  bool _isValidDate(String date) {
    final cleanDate = date.replaceAll(' ', '');
    final regExp = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regExp.hasMatch(cleanDate)) return false;

    try {
      final parts = cleanDate.split('/');
      final d = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final y = int.parse(parts[2]);

      if (m < 1 || m > 12) return false;
      if (d < 1 || d > 31) return false;

      if (m == 2) {
        final isLeap = (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
        if (d > (isLeap ? 29 : 28)) return false;
      } else if ([4, 6, 9, 11].contains(m)) {
        if (d > 30) return false;
      }

      final now = DateTime.now();
      if (y < now.year - 100 || y > now.year) return false;
      if (y == now.year) {
        if (m > now.month) return false;
        if (m == now.month && d > now.day) return false;
      }

      return true;
    } catch (_) {
      return false;
    }
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
            Icon(Icons.person_rounded, color: context.primaryGold, size: 28),
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
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.primaryGold.withValues(alpha: 0.2), width: 1.5),
          ),
          padding: const EdgeInsets.all(5),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: user.photoUrl,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.white10,
                child: const Center(child: CupertinoActivityIndicator(radius: 10)),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white24, size: 40),
            ),
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
