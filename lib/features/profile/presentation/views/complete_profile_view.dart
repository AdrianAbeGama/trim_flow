import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/utils/date_input_formatter.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/features/profile/presentation/widgets/ob_input_field.dart';

/// Onboarding obligatorio: un cliente nuevo debe completar sus datos
/// (nombre, apellido, WhatsApp y cumpleanos) antes de entrar a la app.
class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key, required this.user});

  final UserProfile user;

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthDateController;

  @override
  void initState() {
    super.initState();
    final first = widget.user.firstName == 'Usuario' ? '' : widget.user.firstName;
    _nameController = TextEditingController(text: first);
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
    final clean = date.replaceAll(' ', '');
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(clean)) return false;
    try {
      final parts = clean.split('/');
      final d = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final y = int.parse(parts[2]);
      if (m < 1 || m > 12 || d < 1 || d > 31) return false;
      if (m == 2) {
        final leap = (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
        if (d > (leap ? 29 : 28)) return false;
      } else if ([4, 6, 9, 11].contains(m) && d > 30) {
        return false;
      }
      final now = DateTime.now();
      if (y < now.year - 100 || y > now.year) return false;
      if (y == now.year && (m > now.month || (m == now.month && d > now.day))) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(SaveProfileData(
            firstName: _nameController.text,
            lastName: _lastNameController.text,
            phone: _phoneController.text,
            birthDate: _birthDateController.text,
          ));
    }
  }

  Future<void> _logout() async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Salir sin completar tu perfil?'),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          CupertinoDialogAction(isDestructiveAction: true, onPressed: () => Navigator.pop(ctx, true), child: const Text('Salir')),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<AppModeBloc>().add(const AppModeEvent.requestLogout());
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: BlocListener<ProfileBloc, ProfileState>(
        listenWhen: (p, c) => p.status != c.status && c.status == ProfileStatus.error,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFFCF6679),
              behavior: SnackBarBehavior.floating,
              content: Text('No se pudo guardar. Intenta de nuevo.'),
            ),
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _logout,
                      child: Text('Cerrar sesión', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Bienvenido', style: TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  const Text('Completa tu perfil', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.8, height: 1.1)),
                  const SizedBox(height: 10),
                  Text(
                    'Necesitamos algunos datos para reservar tus citas. Tu fecha de nacimiento solo se registra una vez.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.45),
                  ),
                  const SizedBox(height: 32),
                  ObInputField(
                    label: 'Nombre',
                    controller: _nameController,
                    maxLength: 15,
                    showCounter: true,
                    validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
                  ),
                  ObInputField(
                    label: 'Apellido',
                    controller: _lastNameController,
                    maxLength: 15,
                    showCounter: true,
                    validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
                  ),
                  ObInputField(
                    label: 'WhatsApp',
                    controller: _phoneController,
                    prefix: '+51',
                    hasPrefixDivider: true,
                    maxLength: 9,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo requerido';
                      if (v.length != 9 || !RegExp(r'^\d+$').hasMatch(v)) return 'Número no válido';
                      return null;
                    },
                  ),
                  ObInputField(
                    label: 'Fecha de Nacimiento',
                    controller: _birthDateController,
                    hintText: 'DD / MM / AAAA',
                    keyboardType: TextInputType.number,
                    inputFormatters: [DateInputFormatter()],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo requerido';
                      if (!_isValidDate(v)) return 'Fecha no válida';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      final loading = state.status == ProfileStatus.loading;
                      return ElevatedButton(
                        onPressed: loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: context.backgroundBlack,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                          disabledForegroundColor: Colors.white10,
                        ),
                        child: loading
                            ? CupertinoActivityIndicator(color: context.backgroundBlack)
                            : const Text('CONTINUAR', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
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
}
