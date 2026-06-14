import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/services/auth_service.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

/// Hoja inferior para iniciar sesion con correo (OTP de un solo uso).
/// Paso 1: correo -> envia codigo. Paso 2: codigo -> verifica y entra.
class EmailOtpSheet extends StatefulWidget {
  const EmailOtpSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EmailOtpSheet(),
    );
  }

  @override
  State<EmailOtpSheet> createState() => _EmailOtpSheetState();
}

class _EmailOtpSheetState extends State<EmailOtpSheet> {
  final _auth = getIt<AuthService>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  bool _sent = false;
  bool _loading = false;
  String? _error;
  String _sentEmail = '';

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailController.text.trim();
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _error = 'Escribe un correo válido.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.sendEmailOtp(email);
      if (mounted) {
        setState(() {
          _loading = false;
          _sent = true;
          _sentEmail = email;
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message.contains('disposable')
              ? 'Ese correo no está permitido. Usa uno real.'
              : 'No se pudo enviar el código. Intenta de nuevo.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'No se pudo enviar el código. Intenta de nuevo.';
        });
      }
    }
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length < 6) {
      setState(() => _error = 'El código tiene 6 dígitos.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.verifyEmailOtp(email: _sentEmail, token: code);
      // Sesion abierta -> onAuthStateChange dispara el login. Cerramos la hoja.
      if (mounted) Navigator.pop(context);
    } on AuthException catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Código inválido o expirado. Pide uno nuevo.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'No se pudo verificar. Intenta de nuevo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E0E0E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  _sent ? 'Revisa tu correo' : 'Entra con tu correo',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _sent
                      ? 'Enviamos un código de 6 dígitos a $_sentEmail.'
                      : 'Te enviaremos un código de un solo uso. Sin contraseñas.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.5),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                if (!_sent)
                  _field(
                    controller: _emailController,
                    gold: gold,
                    hint: 'tucorreo@ejemplo.com',
                    keyboardType: TextInputType.emailAddress,
                    onSubmit: _send,
                  )
                else
                  _field(
                    controller: _codeController,
                    gold: gold,
                    hint: '000000',
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    letterSpacing: 6,
                    onSubmit: _verify,
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFF8A95),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _PrimaryButton(
                  label: _sent ? 'VERIFICAR Y ENTRAR' : 'ENVIAR CÓDIGO',
                  loading: _loading,
                  gold: gold,
                  onTap: _sent ? _verify : _send,
                ),
                if (_sent) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _loading
                          ? null
                          : () => setState(() {
                                _sent = false;
                                _error = null;
                                _codeController.clear();
                              }),
                      child: Text(
                        'Usar otro correo',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required Color gold,
    required String hint,
    required TextInputType keyboardType,
    required VoidCallback onSubmit,
    int? maxLength,
    double letterSpacing = 0.5,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      autocorrect: false,
      maxLength: maxLength,
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: letterSpacing,
      ),
      onSubmitted: (_) => onSubmit(),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: letterSpacing,
        ),
        filled: true,
        fillColor: const Color(0xFF161616),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: gold, width: 1.5),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.gold,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final Color gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: loading ? null : onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: loading ? gold.withValues(alpha: 0.4) : gold,
          borderRadius: BorderRadius.circular(16),
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: premiumOnAccent(gold),
                ),
              )
            : Text(
                label,
                style: GoogleFonts.inter(
                  color: premiumOnAccent(gold),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}
