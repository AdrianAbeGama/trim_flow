import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/features/profile/presentation/widgets/ob_input_field.dart';

/// Sheet para editar perfil del barbero (nombre, apellido, WhatsApp).
class BarberProfileEditSheet extends StatefulWidget {
  const BarberProfileEditSheet({super.key, required this.user});

  final UserProfile user;

  @override
  State<BarberProfileEditSheet> createState() => _BarberProfileEditSheetState();
}

class _BarberProfileEditSheetState extends State<BarberProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _lastCtrl;
  late final TextEditingController _phoneCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.firstName);
    _lastCtrl = TextEditingController(text: widget.user.lastName);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileBloc = context.read<ProfileBloc>();
    final gold = context.primaryGold;

    return BlocProvider.value(
      value: profileBloc,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'EDITAR PERFIL',
                    style: GoogleFonts.inter(
                      color: gold,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ObInputField(
                    label: 'Nombre',
                    controller: _nameCtrl,
                    maxLength: 15,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Campo requerido' : null,
                  ),
                  ObInputField(
                    label: 'Apellido',
                    controller: _lastCtrl,
                    maxLength: 15,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Campo requerido' : null,
                  ),
                  ObInputField(
                    label: 'WhatsApp',
                    controller: _phoneCtrl,
                    prefix: '+51',
                    hasPrefixDivider: true,
                    maxLength: 9,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo requerido';
                      if (v.length != 9 || !RegExp(r'^\d+$').hasMatch(v)) {
                        return 'Número no válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  BlocConsumer<ProfileBloc, ProfileState>(
                    listenWhen: (prev, curr) =>
                        _saving && prev.status != curr.status,
                    listener: (context, state) {
                      if (state.status == ProfileStatus.loading) return;
                      _saving = false;
                      final overlay = Overlay.of(context, rootOverlay: true);
                      if (state.status == ProfileStatus.error) {
                        AppToast.showOn(overlay,
                            type: AppToastType.error,
                            title: 'No se pudo guardar',
                            message: 'Revisa tu conexión e intenta otra vez.');
                        return;
                      }
                      Navigator.pop(context);
                      AppToast.showOn(overlay,
                          type: AppToastType.success,
                          title: 'Perfil actualizado',
                          message: 'Tus datos se guardaron.');
                    },
                    builder: (context, state) {
                      final isLoading =
                          state.status == ProfileStatus.loading;
                      return GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  HapticFeedback.mediumImpact();
                                  _saving = true;
                                  context.read<ProfileBloc>().add(
                                        SaveProfileData(
                                          firstName: _nameCtrl.text,
                                          lastName: _lastCtrl.text,
                                          phone: _phoneCtrl.text,
                                          birthDate: '',
                                        ),
                                      );
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isLoading ? Colors.white10 : gold,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: isLoading
                                ? const CupertinoActivityIndicator(color: Colors.black)
                                : Text(
                                    'GUARDAR CAMBIOS',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                          ),
                        ),
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
