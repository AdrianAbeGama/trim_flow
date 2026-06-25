import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/app_mode/claim_intent.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/premium/trimflow_logo.dart';
import 'package:trim_flow/features/auth/presentation/widgets/qr_scanner_facade.dart';
import 'package:trim_flow/features/profile/domain/repositories/profile_repository.dart';

/// Pantalla para vincular la cuenta con un codigo de acceso (TRF-XXXX-XXXX) de
/// una reserva web. Se muestra en cold start (sin barberias vinculadas) y al
/// agregar otra barberia desde el switcher. Mismo estilo del teclado premium:
/// prefijo TRF- fijo, el usuario teclea los digitos o escanea el QR.
class ClaimProfileView extends StatefulWidget {
  const ClaimProfileView({super.key});

  @override
  State<ClaimProfileView> createState() => _ClaimProfileViewState();
}

class _ClaimProfileViewState extends State<ClaimProfileView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _code = '';
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _fullCode {
    if (_code.length <= 4) return 'TRF-$_code';
    return 'TRF-${_code.substring(0, 4)}-${_code.substring(4)}';
  }

  void _onCodeChanged(String value) {
    HapticFeedback.selectionClick();
    setState(() {
      _code = value;
      _error = null;
    });
  }

  String _mapError(String message) {
    if (message.contains('access_code_not_found')) {
      return 'Código no válido. Revísalo e intenta otra vez.';
    }
    if (message.contains('already_claimed')) {
      return 'Esta reserva ya está en otra cuenta.';
    }
    if (message.contains('not_authenticated')) {
      return 'Inicia sesión primero.';
    }
    return 'No se pudo vincular. Intenta de nuevo.';
  }

  Future<void> _scan() async {
    if (_loading) return;
    HapticFeedback.lightImpact();
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerFacade()),
    );
    if (!mounted || result == null) return;
    await _submitCode(result);
  }

  Future<void> _submitCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await getIt<ProfileRepository>().claimProfileByTicket(accessCode: trimmed);
      await getIt<TenantThemeBloc>().refreshFromAuth();
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      claimAnotherIntent.value = false;
      if (Navigator.canPop(context)) Navigator.pop(context);
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = _mapError(e.message);
        });
      }
    } catch (_) {
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
    final complete = _code.length == 8;
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 36),
                TrimflowLogo(size: 52, color: gold)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(begin: 0.94, end: 1.06, duration: 1500.ms, curve: Curves.easeInOut)
                    .shimmer(delay: 400.ms, duration: 1800.ms, color: gold.withValues(alpha: 0.6)),
                const SizedBox(height: 16),
                Text(
                  'TRIMFLOW',
                  style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w300, letterSpacing: 8),
                ).animate().fadeIn(delay: 120.ms, duration: 500.ms),
                const Spacer(),
                Text(
                  'Activa tu cuenta',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.2),
                ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 18, height: 1.5, color: gold),
                    const SizedBox(width: 8),
                    Text(
                      'Ingresa el código de tu reserva',
                      style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ).animate().fadeIn(delay: 220.ms, duration: 500.ms),
                const SizedBox(height: 40),
                PremiumPressable(
                  pressedScale: 1,
                  onTap: _loading ? null : _focusNode.requestFocus,
                  child: _buildCodeDisplay(),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 16, 40, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B7A).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFF6B7A).withValues(alpha: 0.30)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFFF8A95), size: 17),
                          const SizedBox(width: 9),
                          Flexible(
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: const Color(0xFFFFB3BB),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 220.ms)
                      .shakeX(amount: 3, hz: 4, duration: 360.ms),
                SizedBox(
                  width: 0,
                  height: 0,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: !_loading,
                    autofocus: true,
                    showCursor: false,
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    enableSuggestions: false,
                    inputFormatters: [
                      const _UpperCaseFormatter(),
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      LengthLimitingTextInputFormatter(8),
                    ],
                    onChanged: _onCodeChanged,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 12, 40, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: PremiumPressable(
                          pressedScale: 0.96,
                          onTap: _scan,
                          child: Container(
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: gold.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: gold.withValues(alpha: 0.35)),
                            ),
                            child: Icon(Icons.qr_code_scanner_rounded, color: gold, size: 22),
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scaleXY(begin: 0.97, end: 1.04, duration: 1300.ms, curve: Curves.easeInOut),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 3,
                        child: PremiumPressable(
                          pressedScale: 0.97,
                          onTap: complete && !_loading ? () => _submitCode(_fullCode) : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: complete && !_loading ? const Color(0xFFF7F3EC) : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                  )
                                : Text(
                                    'CONFIRMAR',
                                    style: GoogleFonts.inter(
                                      color: complete ? Colors.black : Colors.white.withValues(alpha: 0.3),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 12,
              child: PremiumPressable(
                pressedScale: 0.95,
                onTap: _loading ? null : _onTopRightTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: Text(
                    _topRightLabel(canPop),
                    style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.75), fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeDisplay() {
    final gold = context.primaryGold;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'TRF-',
          style: GoogleFonts.inter(color: gold.withValues(alpha: 0.85), fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 6),
        ..._buildSlots(0, 4, gold),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '-',
            style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.2), fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ),
        ..._buildSlots(4, 8, gold),
      ],
    );
  }

  List<Widget> _buildSlots(int start, int end, Color gold) {
    return List.generate(end - start, (i) {
      final index = start + i;
      final hasChar = index < _code.length;
      return Container(
        width: 22,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: hasChar ? gold : Colors.white.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
        ),
        child: Text(
          hasChar ? _code[index] : '',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: gold, fontSize: 22, fontWeight: FontWeight.w900),
        ),
      );
    });
  }

  String _topRightLabel(bool canPop) {
    if (claimAnotherIntent.value) return 'Volver';
    return canPop ? 'Cerrar' : 'Cerrar sesión';
  }

  void _onTopRightTap() {
    if (claimAnotherIntent.value) {
      claimAnotherIntent.value = false;
      if (Navigator.canPop(context)) Navigator.pop(context);
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    _logout();
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  const _UpperCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
