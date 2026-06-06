import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

const int _kMinuteStep = 5;

/// Selector de hora premium (flechitas ▲▼) — reemplaza el showTimePicker
/// generico de Material. Devuelve 'HH:MM' o null si se cancela.
Future<String?> showPremiumTimePicker(
  BuildContext context, {
  required String title,
  required String initial,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PremiumTimePickerSheet(title: title, initial: initial),
  );
}

int _initHour(String s) {
  if (s.length < 5) return 9;
  return (int.tryParse(s.substring(0, 2)) ?? 9).clamp(0, 23);
}

int _initMinute(String s) {
  if (s.length < 5) return 0;
  final m = int.tryParse(s.substring(3, 5)) ?? 0;
  return ((m / _kMinuteStep).round() * _kMinuteStep) % 60;
}

class _PremiumTimePickerSheet extends StatefulWidget {
  const _PremiumTimePickerSheet({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_PremiumTimePickerSheet> createState() =>
      _PremiumTimePickerSheetState();
}

class _PremiumTimePickerSheetState extends State<_PremiumTimePickerSheet> {
  late int _hour = _initHour(widget.initial);
  late int _minute = _initMinute(widget.initial);

  void _stepHour(int d) => setState(() => _hour = (_hour + d + 24) % 24);

  void _stepMinute(int d) => setState(
      () => _minute = (_minute + d * _kMinuteStep + 60) % 60);

  String get _formatted =>
      '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Stepper(
                label: 'HORA',
                value: _hour.toString().padLeft(2, '0'),
                onUp: () => _stepHour(1),
                onDown: () => _stepHour(-1),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 56),
                child: Text(
                  ':',
                  style: GoogleFonts.inter(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withValues(alpha: 0.3),
                    height: 1,
                  ),
                ),
              ),
              _Stepper(
                label: 'MIN',
                value: _minute.toString().padLeft(2, '0'),
                onUp: () => _stepMinute(1),
                onDown: () => _stepMinute(-1),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: PremiumPressable(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context, _formatted);
              },
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3EC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Listo',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onUp,
    required this.onDown,
  });

  final String label;
  final String value;
  final VoidCallback onUp;
  final VoidCallback onDown;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ArrowBtn(icon: Icons.keyboard_arrow_up_rounded, onTap: onUp),
          const SizedBox(height: 10),
          Container(
            width: 96,
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: gold.withValues(alpha: 0.25)),
            ),
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: gold,
                letterSpacing: -1,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          _ArrowBtn(icon: Icons.keyboard_arrow_down_rounded, onTap: onDown),
        ],
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  const _ArrowBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return PremiumPressable(
      pressedScale: 0.85,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 60,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: gold.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: gold, size: 26),
      ),
    );
  }
}
