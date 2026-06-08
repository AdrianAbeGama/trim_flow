import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/utils/date_input_formatter.dart';
import 'package:core/core.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'ob_input_field.dart';

class ProfileEditSheet extends StatefulWidget {
  final UserProfile user;
  final ProfileBloc profileBloc;
  final bool isBarber;

  const ProfileEditSheet({
    super.key,
    required this.user,
    required this.profileBloc,
    this.isBarber = false,
  });

  @override
  State<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<ProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthDateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _phoneController = TextEditingController(text: widget.user.phone);
    _birthDateController = TextEditingController(text: widget.user.birthDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
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
    // Cumpleanos solo se pone una vez: si ya tiene, queda bloqueado.
    final birthLocked = !widget.isBarber && widget.user.birthDate.trim().isNotEmpty;
    return BlocProvider.value(
      value: widget.profileBloc,
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 40,
        ),
        child: SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 32),
                Text('EDITAR PERFIL', style: TextStyle(color: context.primaryGold, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 40),
                ObInputField(
                  label: 'Nombre',
                  controller: _nameController,
                  maxLength: 15,
                  showCounter: true,
                  validator: (val) => (val == null || val.isEmpty) ? 'Campo requerido' : null,
                ),
                ObInputField(
                  label: 'Apellido',
                  controller: _lastNameController,
                  maxLength: 15,
                  showCounter: true,
                  validator: (val) => (val == null || val.isEmpty) ? 'Campo requerido' : null,
                ),
                ObInputField(
                  label: 'WhatsApp',
                  controller: _phoneController,
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
                if (!widget.isBarber)
                  ObInputField(
                    label: birthLocked
                        ? 'Fecha de Nacimiento (no editable)'
                        : 'Fecha de Nacimiento',
                    controller: _birthDateController,
                    hintText: 'DD / MM / AAAA',
                    readOnly: birthLocked,
                    keyboardType: TextInputType.number,
                    inputFormatters: birthLocked ? null : [DateInputFormatter()],
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
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<ProfileBloc>().add(SaveProfileData(
                            firstName: _nameController.text,
                            lastName: _lastNameController.text,
                            phone: _phoneController.text,
                            birthDate: widget.isBarber ? '' : _birthDateController.text,
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
    );
  }
}
