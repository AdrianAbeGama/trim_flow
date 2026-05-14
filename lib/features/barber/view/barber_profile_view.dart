import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/utils/date_input_formatter.dart';
import 'package:core/core.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/features/profile/presentation/widgets/ob_input_field.dart';

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
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildHeader(context, user),
                const SizedBox(height: 40),

                _buildSection(context, 'NOTIFICACIONES', [
                  _buildNotificationControls(context, user),
                ]),

                const SizedBox(height: 32),

                _buildSection(context, 'DATOS PERSONALES', [
                  _buildDetailItem(
                    context, 
                    'Número de WhatsApp', 
                    user.phone.isEmpty ? 'Pendiente' : '+51 ${user.phone}', 
                    FontAwesomeIcons.whatsapp,
                    onTap: () => _showEditSheet(context, user),
                  ),
                  _buildDetailItem(
                    context, 
                    'Fecha de Nacimiento', 
                    user.birthDate.isEmpty ? 'Pendiente' : user.birthDate, 
                    FontAwesomeIcons.calendarDays,
                    onTap: () => _showEditSheet(context, user),
                  ),
                ]),

                const SizedBox(height: 40),
                
                // Botón de Cambio de Módulo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<AppModeBloc>().add(const AppModeEvent.changeMode(AppMode.client));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: context.primaryGold.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: const Text(
                      'CAMBIAR A MODO CLIENTE',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                    ),
                  ),
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

  Widget _buildHeader(BuildContext context, UserProfile user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.person_rounded, color: context.primaryGold, size: 28),
          const SizedBox(height: 10),
          const Text(
            'PERFIL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 14),
          Container(width: 40, height: 2, color: context.primaryGold),
          const SizedBox(height: 32),
          
          // ID y Editar Fila
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: context.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.primaryGold.withValues(alpha: 0.3)),
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
              TextButton.icon(
                onPressed: () => _showEditSheet(context, user),
                icon: const Icon(Icons.edit_note_rounded, size: 14, color: Colors.white60),
                label: const Text(
                  'EDITAR PERFIL',
                  style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Información Centrada
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(context, user.photoUrl),
                const SizedBox(height: 24),
                
                // Nombre
                Text(
                  '${user.firstName} ${user.lastName}'.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),

                // Correo
                Text(
                  user.email,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String url) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.primaryGold.withValues(alpha: 0.2), width: 1),
      ),
      padding: const EdgeInsets.all(5),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
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

  Widget _buildNotificationControls(BuildContext context, UserProfile user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notificaciones de Sistema', style: TextStyle(color: Colors.white, fontSize: 15)),
              TextButton(
                onPressed: () => context.read<ProfileBloc>().add(const RequestNotificationPermissionEvent()),
                style: TextButton.styleFrom(
                  backgroundColor: user.notificationsEnabled ? Colors.green.withValues(alpha: 0.05) : context.primaryGold.withValues(alpha: 0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  user.notificationsEnabled ? 'HABILITADO' : 'HABILITAR',
                  style: TextStyle(
                    color: user.notificationsEnabled ? Colors.greenAccent : context.primaryGold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTestNotificationMenu(context),
        ],
      ),
    );
  }

  Widget _buildTestNotificationMenu(BuildContext context) {
    return PopupMenuButton<ProfileNotificationType>(
      onSelected: (type) => context.read<ProfileBloc>().add(TestNotificationEvent(type: type, mode: AppMode.barber)),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        _buildPopupItem(context, ProfileNotificationType.offer, 'Nuevo Pedido', Icons.shopping_basket_rounded),
        _buildPopupItem(context, ProfileNotificationType.birthday, 'Cita Finalizada', Icons.check_circle_rounded),
        _buildPopupItem(context, ProfileNotificationType.reservation, 'Recordatorio de Turno', Icons.alarm_rounded),
      ],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_active_rounded, color: context.primaryGold, size: 16),
            const SizedBox(width: 12),
            const Text('PRUEBA DE NOTIFICACIONES', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<ProfileNotificationType> _buildPopupItem(BuildContext context, ProfileNotificationType type, String label, IconData icon) {
    return PopupMenuItem(
      value: type,
      child: Row(
        children: [
          Icon(icon, color: context.primaryGold, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value, dynamic icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            FaIcon(icon, color: context.primaryGold.withValues(alpha: 0.4), size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    value, 
                    style: TextStyle(
                      color: value == 'Pendiente' ? Colors.redAccent.withValues(alpha: 0.5) : Colors.white, 
                      fontSize: 14, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.chevron_right_rounded, color: Colors.white10, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextButton(
        onPressed: () => context.read<AppModeBloc>().add(const AppModeEvent.requestLogout()),
        child: const Text(
          'CERRAR SESIÓN',
          style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
      ),
    );
  }
}
