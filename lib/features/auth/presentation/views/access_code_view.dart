import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/premium/trimflow_logo.dart';
import 'package:trim_flow/features/auth/presentation/widgets/qr_scanner_facade.dart';

class AccessCodeView extends StatefulWidget {
  const AccessCodeView({super.key, required this.onCodeValidated});

  final Function(String code) onCodeValidated;

  @override
  State<AccessCodeView> createState() => _AccessCodeViewState();
}

class _AccessCodeViewState extends State<AccessCodeView> {
  String _code = "";

  void _onNumberPressed(String number) {
    if (_code.length < 10) {
      HapticFeedback.selectionClick();
      setState(() => _code += number);
    }
  }

  void _onDelete() {
    if (_code.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() => _code = _code.substring(0, _code.length - 1));
    }
  }

  void _onConfirm() {
    if (_code == "1" || _code == "2") {
      HapticFeedback.mediumImpact();
      widget.onCodeValidated(_code);
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Código inválido. Usa 1 o 2.',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
          ),
          backgroundColor: const Color(0xFF1A1011),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0x55CF6679)),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Scaffold(
      backgroundColor: context.backgroundBlack,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 36),
            TrimflowLogo(size: 52, color: gold)
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text(
              'TRIMFLOW',
              style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w300, letterSpacing: 8),
            ).animate().fadeIn(delay: 120.ms, duration: 500.ms),
            const Spacer(),
            Text(
              'Identifícate',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1.4),
            ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 500.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 18, height: 1.5, color: gold),
                const SizedBox(width: 8),
                Text(
                  'Ingresa tu código de acceso',
                  style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ).animate().fadeIn(delay: 220.ms, duration: 500.ms),
            const SizedBox(height: 44),
            _buildCodeDisplay(),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 16),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map((n) => _buildKey(n)),
                  const SizedBox.shrink(),
                  _buildKey('0'),
                  _buildKey('back', isIcon: true),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 12, 40, 30),
              child: Row(
                children: [
                  Expanded(
                    child: PremiumPressable(
                      pressedScale: 0.96,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final result = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(builder: (context) => const QrScannerFacade()),
                        );
                        if (result != null) {
                          widget.onCodeValidated(result);
                        }
                      },
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Icon(Icons.qr_code_scanner_rounded, color: gold, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 3,
                    child: PremiumPressable(
                      pressedScale: 0.97,
                      onTap: _code.isNotEmpty ? _onConfirm : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _code.isNotEmpty ? const Color(0xFFF7F3EC) : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'CONFIRMAR',
                          style: GoogleFonts.inter(
                            color: _code.isNotEmpty ? Colors.black : Colors.white.withValues(alpha: 0.3),
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
      ),
    );
  }

  Widget _buildCodeDisplay() {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(10, (index) {
          final hasChar = index < _code.length;
          return Container(
            width: 25,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: hasChar ? gold : Colors.white.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
            ),
            child: Text(
              hasChar ? _code[index] : "",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: gold, fontSize: 24, fontWeight: FontWeight.w900),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildKey(String label, {bool isIcon = false}) {
    return PremiumPressable(
      pressedScale: 0.92,
      onTap: () => isIcon ? _onDelete() : _onNumberPressed(label),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Center(
          child: isIcon
              ? Icon(Icons.backspace_outlined, color: Colors.white.withValues(alpha: 0.4), size: 19)
              : Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400)),
        ),
      ),
    );
  }
}
