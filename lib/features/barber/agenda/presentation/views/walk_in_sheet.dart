import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/barber/agenda/domain/repositories/agenda_repository.dart';

class WalkInResult {
  final String customerName;
  final String customerPhone;
  final DateTime startTime;

  const WalkInResult({
    required this.customerName,
    required this.customerPhone,
    required this.startTime,
  });
}

class WalkInSheet extends StatefulWidget {
  const WalkInSheet({
    super.key,
    required this.refs,
    required this.now,
  });

  final AgendaLookupRefs refs;
  final DateTime now;

  @override
  State<WalkInSheet> createState() => _WalkInSheetState();
}

class _WalkInSheetState extends State<WalkInSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = _ceilToFiveMinutes(widget.now);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  DateTime _ceilToFiveMinutes(DateTime dt) {
    final remainder = dt.minute % 5;
    if (remainder == 0) return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);
    return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute + (5 - remainder));
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: context.primaryGold,
            surface: const Color(0xFF111111),
          ),
        ),
        child: child!,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _startTime = DateTime(
        _startTime.year,
        _startTime.month,
        _startTime.day,
        result.hour,
        result.minute,
      );
    });
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) return;
    Navigator.of(context).pop<WalkInResult>(WalkInResult(
      customerName: _nameCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
      startTime: _startTime,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final hasMissingRefs = widget.refs.defaultBranchId == null || widget.refs.defaultServiceId == null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E0E0E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 3,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                FaIcon(FontAwesomeIcons.personWalking, color: gold, size: 14),
                const SizedBox(width: 10),
                Text(
                  'REGISTRAR WALK-IN',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(width: 32, height: 2, color: gold),
            const SizedBox(height: 18),
            if (hasMissingRefs) ...[
              _MissingRefsWarning(gold: gold),
              const SizedBox(height: 16),
            ],
            _LabeledField(
              label: 'NOMBRE DEL CLIENTE',
              controller: _nameCtrl,
              hint: 'Ej. Pedro Salazar',
              gold: gold,
            ),
            const SizedBox(height: 14),
            _LabeledField(
              label: 'WHATSAPP (OPCIONAL)',
              controller: _phoneCtrl,
              hint: '999 999 999',
              gold: gold,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _TimeRow(startTime: _startTime, onPick: _pickTime, gold: gold),
            const SizedBox(height: 22),
            PremiumPressable(
              pressedScale: 0.98,
              onTap: hasMissingRefs
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      _submit();
                    },
              child: Container(
                width: double.infinity,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: hasMissingRefs ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF7F3EC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'CONFIRMAR WALK-IN',
                  style: GoogleFonts.inter(
                    color: hasMissingRefs ? Colors.white.withValues(alpha: 0.3) : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.gold,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final Color gold;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: gold.withValues(alpha: 0.7),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          cursorColor: gold,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF161616),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: gold.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: gold.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: gold.withValues(alpha: 0.55), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.startTime, required this.onPick, required this.gold});

  final DateTime startTime;
  final VoidCallback onPick;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    final hh = startTime.hour.toString().padLeft(2, '0');
    final mm = startTime.minute.toString().padLeft(2, '0');
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HORA DE INICIO',
                style: GoogleFonts.inter(
                  color: gold.withValues(alpha: 0.7),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$hh:$mm',
                style: GoogleFonts.inter(
                  color: gold,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        PremiumPressable(
          pressedScale: 0.95,
          onTap: () {
            HapticFeedback.lightImpact();
            onPick();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: gold.withValues(alpha: 0.4)),
            ),
            child: Text(
              'CAMBIAR',
              style: GoogleFonts.inter(
                color: gold,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MissingRefsWarning extends StatelessWidget {
  const _MissingRefsWarning({required this.gold});
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x33CF6679),
        border: Border.all(color: const Color(0x99CF6679), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const FaIcon(FontAwesomeIcons.triangleExclamation, color: Color(0xFFE3A0AC), size: 14),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Falta asignar sucursal o servicio activo en tu perfil.',
              style: GoogleFonts.inter(
                color: const Color(0xFFE3A0AC),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
