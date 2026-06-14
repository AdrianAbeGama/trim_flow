import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/premium/trimflow_logo.dart';
import 'package:trim_flow/features/profile/domain/repositories/profile_repository.dart';

/// Pantalla para vincular la cuenta con un codigo de acceso (TRF-XXXX) de una
/// reserva web. Se muestra cuando el cliente no tiene barberias vinculadas
/// (cold start) y tambien al agregar otra barberia desde el switcher.
class ClaimProfileView extends StatefulWidget {
  const ClaimProfileView({super.key});

  @override
  State<ClaimProfileView> createState() => _ClaimProfileViewState();
}

class _ClaimProfileViewState extends State<ClaimProfileView> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _mapError(String message) {
    if (message.contains('access_code_not_found')) {
      return 'Ese código no es válido. Revisa que lo copiaste completo de tu confirmación.';
    }
    if (message.contains('already_claimed')) {
      return 'Esta reserva ya está vinculada a otra cuenta. Contacta a la barbería.';
    }
    if (message.contains('not_authenticated')) {
      return 'Inicia sesión primero.';
    }
    return 'No se pudo vincular. Intenta de nuevo.';
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Escribe tu código de acceso.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await getIt<ProfileRepository>().claimProfileByTicket(accessCode: code);
      // Refresca el Hub → el gate de la app detecta las nuevas barberias.
      await getIt<TenantThemeBloc>().refreshFromAuth();
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      if (Navigator.canPop(context)) Navigator.pop(context);
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = _mapError(e.message);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'No se pudo vincular. Intenta de nuevo.';
        });
      }
    }
  }

  void _logout() {
    HapticFeedback.lightImpact();
    getIt<AppModeBloc>().add(const AppModeEvent.requestLogout());
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final canPop = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: canPop ? () => Navigator.pop(context) : _logout,
                  child: Text(
                    canPop ? 'Cerrar' : 'Cerrar sesión',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TrimflowLogo(size: 48, color: gold),
              const SizedBox(height: 24),
              Text(
                'Activa tu cuenta',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '¿Reservaste en la web? Pega el código de acceso de tu '
                'confirmación (TRF-XXXX-XXXX) para vincular tu cuenta y ver '
                'tus barberías aquí.',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'CÓDIGO DE ACCESO',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'TRF-XXXX-XXXX',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF141414),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: gold, width: 1.5),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFF8A95),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _ClaimButton(loading: _loading, gold: gold, onTap: _submit),
              const SizedBox(height: 18),
              Text(
                'Tu código es privado, no lo compartas. Si aún no reservaste, '
                'hazlo primero en la web de tu barbería.',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({
    required this.loading,
    required this.gold,
    required this.onTap,
  });

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
                'VINCULAR CUENTA',
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
