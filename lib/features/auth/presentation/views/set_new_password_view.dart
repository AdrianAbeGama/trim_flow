import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/services/auth_service.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/premium/trimflow_logo.dart';

/// Pantalla que aparece cuando el barbero abre el link de "olvide mi
/// contrasena". Pone su clave nueva sin salir de la app.
class SetNewPasswordView extends StatefulWidget {
  const SetNewPasswordView({super.key});

  @override
  State<SetNewPasswordView> createState() => _SetNewPasswordViewState();
}

class _SetNewPasswordViewState extends State<SetNewPasswordView> {
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  final _confirmFocus = FocusNode();
  bool _obscure = true;
  bool _saving = false;

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _toast(AppToastType type, String title, String message) {
    AppToast.showOn(Overlay.of(context, rootOverlay: true),
        type: type, title: title, message: message);
  }

  Future<void> _save() async {
    if (_saving) return;
    final p = _pass.text;
    final c = _confirm.text;
    if (p.length < 6) {
      _toast(AppToastType.error, 'Contraseña corta',
          'Usa al menos 6 caracteres.');
      return;
    }
    if (p != c) {
      _toast(AppToastType.error, 'No coinciden',
          'Las dos contraseñas deben ser iguales.');
      return;
    }
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    final bloc = context.read<AppModeBloc>();
    setState(() => _saving = true);
    try {
      await getIt<AuthService>().updatePassword(p);
      if (!mounted) return;
      bloc.add(const AppModeEvent.passwordRecoveryFinished());
      _toast(AppToastType.success, 'Contraseña actualizada',
          'Ya puedes entrar con tu nueva clave.');
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      _toast(AppToastType.error, 'No se pudo guardar',
          'Intenta de nuevo en un momento.');
    }
  }

  void _cancel() {
    context.read<AppModeBloc>().add(const AppModeEvent.requestLogout());
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: TrimflowLogo(size: 70, color: gold))
                    .animate()
                    .fadeIn(duration: 450.ms)
                    .scaleXY(begin: 0.9, end: 1, duration: 450.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 26),
                Text(
                  'NUEVA CONTRASEÑA',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ).animate().fadeIn(delay: 120.ms, duration: 450.ms),
                const SizedBox(height: 8),
                Text(
                  'Crea tu clave para entrar con tu correo',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 450.ms),
                const SizedBox(height: 30),
                _field(
                  controller: _pass,
                  hint: 'Nueva contraseña',
                  gold: gold,
                  obscure: _obscure,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _confirmFocus.requestFocus(),
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white.withValues(alpha: 0.35),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _confirm,
                  focusNode: _confirmFocus,
                  hint: 'Repetir contraseña',
                  gold: gold,
                  obscure: _obscure,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 22),
                PremiumPressable(
                  pressedScale: 0.97,
                  onTap: _save,
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F3EC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.6, color: Colors.black),
                          )
                        : Text(
                            'GUARDAR CONTRASEÑA',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 450.ms)
                    .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 450.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _cancel,
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required Color gold,
    FocusNode? focusNode,
    bool obscure = false,
    Widget? suffix,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        cursorColor: gold,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 15,
          ),
          prefixIcon: Icon(Icons.lock_outline_rounded,
              color: Colors.white.withValues(alpha: 0.35), size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}
