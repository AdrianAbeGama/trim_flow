import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_primitives.dart';

String _uuidV4() {
  final r = Random();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  String h(int x) => x.toRadixString(16).padLeft(2, '0');
  final s = b.map(h).join();
  return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-'
      '${s.substring(16, 20)}-${s.substring(20)}';
}

typedef _Reason = ({String code, String label});

const List<_Reason> _kReasons = [
  (code: 'courtesy_discount', label: 'Cortesía'),
  (code: 'correction_typo', label: 'Corrección'),
  (code: 'service_complaint', label: 'Queja'),
  (code: 'double_charge', label: 'Cobro doble'),
  (code: 'other', label: 'Otro'),
];

/// Abre el sheet de ajuste de caja. `onSubmit` ejecuta la mutación; el sheet
/// muestra carga y solo se cierra (devolviendo true) tras éxito.
Future<bool?> showCashAdjust(
  BuildContext context, {
  required Future<void> Function(double amount, String reasonCode,
          String? reasonText, String idempotencyKey)
      onSubmit,
}) {
  return showAdminSheet<bool>(context, _CashAdjustSheet(onSubmit: onSubmit));
}

class _CashAdjustSheet extends StatefulWidget {
  const _CashAdjustSheet({required this.onSubmit});

  final Future<void> Function(double, String, String?, String) onSubmit;

  @override
  State<_CashAdjustSheet> createState() => _CashAdjustSheetState();
}

class _CashAdjustSheetState extends State<_CashAdjustSheet> {
  bool _income = true;
  int _reasonIndex = 1;
  bool _saving = false;
  final String _idem = _uuidV4();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _textCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) return adminSnack(context, 'Pon un monto válido');
    final reason = _kReasons[_reasonIndex];
    final text = _textCtrl.text.trim();
    if (reason.code == 'other' && text.isEmpty) {
      return adminSnack(context, 'Escribe el motivo');
    }
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    try {
      await widget.onSubmit(_income ? amount : -amount, reason.code,
          text.isEmpty ? null : text, _idem);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      adminSnack(context, 'No se pudo registrar el ajuste');
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOther = _kReasons[_reasonIndex].code == 'other';
    return AdminSheetScaffold(
      title: 'Ajuste de caja',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AdminChoiceChip(
                label: 'Ingreso (+)',
                selected: _income,
                expand: true,
                onTap: () => setState(() => _income = true),
              ),
              const SizedBox(width: 8),
              AdminChoiceChip(
                label: 'Egreso (−)',
                selected: !_income,
                expand: true,
                onTap: () => setState(() => _income = false),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AdminTextField(
            controller: _amountCtrl,
            label: 'Monto (S/)',
            number: true,
          ),
          const SizedBox(height: 16),
          Text(
            'MOTIVO',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.45),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _kReasons.length; i++)
                AdminChoiceChip(
                  label: _kReasons[i].label,
                  selected: _reasonIndex == i,
                  onTap: () => setState(() => _reasonIndex = i),
                ),
            ],
          ),
          if (isOther) ...[
            const SizedBox(height: 12),
            AdminTextField(controller: _textCtrl, hint: 'Describe el motivo'),
          ],
          const SizedBox(height: 20),
          AdminPrimaryButton(
            label: 'Registrar ajuste',
            loading: _saving,
            onTap: _save,
          ),
        ],
      ),
    );
  }
}
