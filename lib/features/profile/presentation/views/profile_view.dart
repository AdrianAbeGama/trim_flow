import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/constants/app_colors.dart';
import 'package:trim_flow/features/profile/domain/models/user_profile.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(LoadProfileEvent()),
      child: const ProfileContent(),
    );
  }
}

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _birthDateController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _syncControllers(UserProfile user) {
    if (_nameController.text.isEmpty) _nameController.text = user.firstName;
    if (_lastNameController.text.isEmpty) _lastNameController.text = user.lastName;
    if (_phoneController.text.isEmpty) _phoneController.text = user.phone;
    if (_birthDateController.text.isEmpty) _birthDateController.text = user.birthDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.updated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil guardado', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.black,
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const Center(child: CupertinoActivityIndicator(color: AppColors.gold));
          }

          final user = state.user;
          if (user == null) return const SizedBox.shrink();
          _syncControllers(user);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 80),
                // Avatar simple
                _buildAvatar(user.photoUrl),
                const SizedBox(height: 24),
                
                // Nombre y Email
                _buildIdentity(user, state.isEditing),
                const SizedBox(height: 48),

                // Secciones de información
                _buildSection('CONFIGURACIÓN', [
                  _buildItem(
                    label: 'Notificaciones',
                    trailing: CupertinoSwitch(
                      value: user.notificationsEnabled,
                      activeTrackColor: AppColors.gold,
                      onChanged: (val) => context.read<ProfileBloc>().add(ToggleNotificationsEvent(enabled: val)),
                    ),
                  ),
                  _buildItem(
                    label: state.isEditing ? 'Guardar Cambios' : 'Editar Perfil',
                    onTap: () {
                      if (state.isEditing) {
                        context.read<ProfileBloc>().add(UpdateProfileEvent(
                          firstName: _nameController.text,
                          lastName: _lastNameController.text,
                          phone: _phoneController.text,
                          birthDate: _birthDateController.text,
                        ));
                      } else {
                        context.read<ProfileBloc>().add(ToggleEditModeEvent());
                      }
                    },
                    trailing: Icon(
                      state.isEditing ? Icons.check_circle_outline : Icons.edit_outlined,
                      color: AppColors.gold,
                      size: 20,
                    ),
                  ),
                ]),

                const SizedBox(height: 32),
                _buildSection('DATOS PERSONALES', [
                  _buildDetailItem('WhatsApp', user.phone, _phoneController, state.isEditing, prefix: '+51 '),
                  _buildDetailItem('Nacimiento', user.birthDate, _birthDateController, state.isEditing, onTap: () => _selectDate(context)),
                ]),

                const SizedBox(height: 32),
                _buildSection('ACTIVIDAD', [
                  _buildHistoryItem(user.history),
                ]),

                const SizedBox(height: 48),
                _buildLogout(),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: CircleAvatar(
        radius: 45,
        backgroundImage: NetworkImage(url),
      ),
    );
  }

  Widget _buildIdentity(UserProfile user, bool isEditing) {
    if (isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            _buildMinimalField(_nameController, 'Nombre'),
            _buildMinimalField(_lastNameController, 'Apellido'),
          ],
        ),
      );
    }
    return Column(
      children: [
        Text(
          '${user.firstName} ${user.lastName}',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: TextStyle(color: AppColors.gold.withValues(alpha: 0.5), fontSize: 10, letterSpacing: 1.5),
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

  Widget _buildItem({required String label, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
      trailing: trailing,
    );
  }

  Widget _buildDetailItem(String label, String value, TextEditingController controller, bool isEditing, {String? prefix, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          if (isEditing)
            SizedBox(
              width: 150,
              child: onTap != null
                  ? InkWell(
                      onTap: onTap,
                      child: Text(controller.text, style: const TextStyle(color: AppColors.gold, fontSize: 14), textAlign: TextAlign.right),
                    )
                  : TextField(
                      controller: controller,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: AppColors.gold, fontSize: 14),
                      decoration: InputDecoration(
                        prefixText: prefix,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
            )
          else
            Text(value, style: const TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMinimalField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildHistoryItem(List<CuttingRecord> history) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 24),
      title: const Text('Historial de Cortes', style: TextStyle(color: Colors.white, fontSize: 15)),
      iconColor: AppColors.gold,
      collapsedIconColor: Colors.white24,
      shape: const Border(),
      children: history.map((record) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 40),
        title: Text(record.day, style: const TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: Text('${record.time} • ${record.price}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
        trailing: TextButton(
          onPressed: () {},
          child: const Text('REPETIR', style: TextStyle(color: AppColors.gold, fontSize: 10)),
        ),
      )).toList(),
    );
  }

  Widget _buildLogout() {
    return TextButton(
      onPressed: () {},
      child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontSize: 15)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.gold, onPrimary: Colors.black)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked));
    }
  }
}
