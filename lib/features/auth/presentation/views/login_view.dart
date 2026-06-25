import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/app_mode/bootstrap_mode.dart';
import 'package:trim_flow/core/app_mode/claim_intent.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/services/auth_service.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/premium/trimflow_logo.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key, required this.onLoginSuccess});

  final VoidCallback onLoginSuccess;

  @override
  Widget build(BuildContext context) {
    // La app barbero entra con correo + contrasena; el cliente con Google.
    return currentBootstrapMode.isBusiness
        ? const _BarberLoginView()
        : const _ClientLoginView();
  }
}

class _ClientLoginView extends StatelessWidget {
  const _ClientLoginView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            TrimflowLogo(size: 104, color: context.primaryGold)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.95, end: 1.05, duration: 1600.ms, curve: Curves.easeInOut)
                .shimmer(delay: 400.ms, duration: 1900.ms, color: context.primaryGold.withValues(alpha: 0.6)),
            const SizedBox(height: 40),
            const Text(
              'BIENVENIDO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 500.ms)
                .slideY(begin: 0.25, end: 0, delay: 150.ms, duration: 500.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 12),
            Text(
              'ELEVA TU ESTILO CON TRIMFLOW',
              style: TextStyle(
                color: context.primaryGold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ).animate().fadeIn(delay: 280.ms, duration: 500.ms),
            const Spacer(flex: 2),
            GestureDetector(
              onTap: () {
                claimAnotherIntent.value = false;
                context.read<AppModeBloc>().add(const AppModeEvent.loginWithGoogle());
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/google.png', height: 24),
                    const SizedBox(width: 16),
                    const Text(
                      'CONTINUAR CON GOOGLE',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 420.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0, delay: 420.ms, duration: 500.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 20),
            Text(
              'Acceso rápido y seguro',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 11,
                letterSpacing: 1,
              ),
            ).animate().fadeIn(delay: 560.ms, duration: 500.ms),
            const SizedBox(height: 8),
            Text(
              '¿Primera vez? Entra y luego pon el código de tu reserva.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 11.5,
                letterSpacing: 0.2,
                height: 1.4,
              ),
            ).animate().fadeIn(delay: 640.ms, duration: 500.ms),
            const SizedBox(height: 18),
            PremiumPressable(
              pressedScale: 0.97,
              onTap: () {
                HapticFeedback.lightImpact();
                claimAnotherIntent.value = true;
                context.read<AppModeBloc>().add(const AppModeEvent.loginWithGoogle());
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.primaryGold.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '¿Tienes un código de otra barbería?',
                  style: TextStyle(
                    color: context.primaryGold,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 720.ms, duration: 500.ms),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

class _BarberLoginView extends StatefulWidget {
  const _BarberLoginView();

  @override
  State<_BarberLoginView> createState() => _BarberLoginViewState();
}

class _BarberLoginViewState extends State<_BarberLoginView> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _passFocus = FocusNode();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _toast(AppToastType type, String title, String message) {
    AppToast.showOn(Overlay.of(context, rootOverlay: true),
        type: type, title: title, message: message);
  }

  Future<void> _login() async {
    if (_loading) return;
    final email = _email.text.trim();
    final pass = _pass.text;
    if (email.isEmpty || pass.isEmpty) {
      _toast(AppToastType.error, 'Faltan datos',
          'Ingresa tu correo y contraseña.');
      return;
    }
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    try {
      await getIt<AuthService>()
          .signInWithPassword(email: email, password: pass);
      // El login lo completa onAuthStateChange (AppModeBloc). Dejamos el
      // spinner hasta que la vista se reemplace.
    } on AuthException catch (e) {
      if (mounted) setState(() => _loading = false);
      _toast(AppToastType.error, 'No se pudo entrar', _friendlyAuth(e.message));
    } catch (_) {
      if (mounted) setState(() => _loading = false);
      _toast(AppToastType.error, 'No se pudo entrar',
          'Revisa tu conexión e intenta otra vez.');
    }
  }

  String _friendlyAuth(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('email not confirmed')) {
      return 'Tu correo aún no está confirmado.';
    }
    return 'Correo o contraseña incorrectos.';
  }

  Future<void> _forgot() async {
    HapticFeedback.lightImpact();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ForgotPasswordSheet(initialEmail: _email.text.trim()),
    );
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
                Center(child: TrimflowLogo(size: 76, color: gold))
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scaleXY(begin: 0.9, end: 1, duration: 500.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 28),
                Text(
                  'ACCESO BARBERO',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn(delay: 120.ms, duration: 450.ms),
                const SizedBox(height: 8),
                Text(
                  'Ingresa con tu correo y contraseña',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 450.ms),
                const SizedBox(height: 32),
                _field(
                  controller: _email,
                  hint: 'Correo electrónico',
                  icon: Icons.mail_outline_rounded,
                  gold: gold,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passFocus.requestFocus(),
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _pass,
                  focusNode: _passFocus,
                  hint: 'Contraseña',
                  icon: Icons.lock_outline_rounded,
                  gold: gold,
                  obscure: _obscure,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
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
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgot,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: GoogleFonts.inter(
                        color: gold,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                PremiumPressable(
                  pressedScale: 0.97,
                  onTap: _login,
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F3EC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.6, color: Colors.black),
                          )
                        : Text(
                            'INGRESAR',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 320.ms, duration: 450.ms)
                    .slideY(begin: 0.2, end: 0, delay: 320.ms, duration: 450.ms, curve: Curves.easeOutCubic),
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
    required IconData icon,
    required Color gold,
    FocusNode? focusNode,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
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
        keyboardType: keyboardType,
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
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.35), size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}

class _ForgotPasswordSheet extends StatefulWidget {
  const _ForgotPasswordSheet({required this.initialEmail});

  final String initialEmail;

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  late final TextEditingController _email =
      TextEditingController(text: widget.initialEmail);
  bool _sending = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;
    final email = _email.text.trim();
    final overlay = Overlay.of(context, rootOverlay: true);
    final navigator = Navigator.of(context);
    if (email.isEmpty || !email.contains('@')) {
      AppToast.showOn(overlay,
          type: AppToastType.error,
          title: 'Correo inválido',
          message: 'Escribe un correo válido.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    try {
      await getIt<AuthService>().sendPasswordReset(email);
      navigator.pop();
      AppToast.showOn(overlay,
          type: AppToastType.success,
          title: 'Correo enviado',
          message: 'Revisa tu bandeja para restablecer tu contraseña.');
    } catch (_) {
      if (mounted) setState(() => _sending = false);
      AppToast.showOn(overlay,
          type: AppToastType.error,
          title: 'No se pudo enviar',
          message: 'Intenta de nuevo en un momento.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Restablecer contraseña',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Te enviaremos un enlace a tu correo.',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _send(),
                  cursorColor: gold,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(Icons.mail_outline_rounded,
                        color: Colors.white.withValues(alpha: 0.35), size: 20),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              PremiumPressable(
                pressedScale: 0.97,
                onTap: _send,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F3EC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.black),
                        )
                      : Text(
                          'ENVIAR ENLACE',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
