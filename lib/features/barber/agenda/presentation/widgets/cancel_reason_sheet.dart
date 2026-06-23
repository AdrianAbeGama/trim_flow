import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

class CancelResult {
  const CancelResult({required this.reasonCode, this.note});
  final String reasonCode;
  final String? note;
}

class _ReasonOption {
  const _ReasonOption(this.code, this.label);
  final String code;
  final String label;
}

const List<_ReasonOption> _kReasons = [
  _ReasonOption('client_request', 'El cliente lo pidió'),
  _ReasonOption('barber_unavailable', 'No estaré disponible'),
  _ReasonOption('scheduling_error', 'Error de agenda'),
  _ReasonOption('other', 'Otro motivo'),
];

/// Sheet para elegir el motivo de cancelacion. La nota solo es obligatoria
/// cuando se elige "Otro". Devuelve un [CancelResult] o null si se descarta.
class CancelReasonSheet extends StatefulWidget {
  const CancelReasonSheet({super.key});

  @override
  State<CancelReasonSheet> createState() => _CancelReasonSheetState();
}

class _CancelReasonSheetState extends State<CancelReasonSheet> {
  String? _selected;
  final _noteController = TextEditingController();

  bool get _isOther => _selected == 'other';
  bool get _canConfirm =>
      _selected != null &&
      (!_isOther || _noteController.text.trim().isNotEmpty);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_canConfirm) return;
    HapticFeedback.mediumImpact();
    final note = _noteController.text.trim();
    Navigator.pop(
      context,
      CancelResult(reasonCode: _selected!, note: note.isEmpty ? null : note),
    );
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
                'Cancelar cita',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Elige el motivo. Se avisará al cliente para reagendar.',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < _kReasons.length; i++) ...[
                if (i > 0)
                  Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                _reasonRow(_kReasons[i], gold),
              ],
              if (_isOther) ...[
                const SizedBox(height: 6),
                TextField(
                  controller: _noteController,
                  onChanged: (_) => setState(() {}),
                  autofocus: true,
                  maxLength: 120,
                  minLines: 1,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: gold,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Escribe el motivo',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 14,
                    ),
                    counterText: '',
                    isDense: true,
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: gold, width: 1.5),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              PremiumPressable(
                pressedScale: _canConfirm ? 0.97 : 1,
                onTap: _confirm,
                child: AnimatedOpacity(
                  opacity: _canConfirm ? 1 : 0.4,
                  duration: const Duration(milliseconds: 160),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F3EC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'CANCELAR CITA',
                      style: GoogleFonts.inter(
                        color: Colors.black,
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
      ),
    );
  }

  Widget _reasonRow(_ReasonOption r, Color gold) {
    final selected = _selected == r.code;
    return PremiumPressable(
      pressedScale: 0.99,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selected = r.code);
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 21,
              color: selected ? gold : Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                r.label,
                style: GoogleFonts.inter(
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
