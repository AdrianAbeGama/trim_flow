import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/domain/models/admin_promotion.dart';

typedef _Preset = ({String label, DateTime? value});

Future<AdminPromotion?> showPromotionForm(
  BuildContext context, {
  AdminPromotion? promo,
}) {
  return showModalBottomSheet<AdminPromotion>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PromotionForm(original: promo),
  );
}

class _PromotionForm extends StatefulWidget {
  const _PromotionForm({this.original});

  final AdminPromotion? original;

  @override
  State<_PromotionForm> createState() => _PromotionFormState();
}

class _PromotionFormState extends State<_PromotionForm> {
  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.original?.name ?? '');
  late final TextEditingController _codeCtrl =
      TextEditingController(text: widget.original?.code ?? '');
  late final TextEditingController _valueCtrl = TextEditingController(
    text: widget.original == null ? '' : _fmt(widget.original!.discountValue),
  );

  late bool _percentage = widget.original?.isPercentage ?? true;
  late bool _active = widget.original?.isActive ?? true;
  late final List<_Preset> _presets;
  int _presetIndex = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _presets = [
      if (widget.original?.validUntil != null)
        (label: 'Mantener', value: widget.original!.validUntil),
      (label: 'Sin vencimiento', value: null),
      (label: '1 mes', value: now.add(const Duration(days: 30))),
      (label: '3 meses', value: now.add(const Duration(days: 90))),
      (label: '6 meses', value: now.add(const Duration(days: 180))),
    ];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A1A),
        content: Text(text, style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final code = _codeCtrl.text.trim().toUpperCase().replaceAll(' ', '');
    final value = double.tryParse(_valueCtrl.text.trim().replaceAll(',', '.'));
    if (name.isEmpty) return _snack('Ponle un nombre a la promoción');
    if (code.isEmpty) return _snack('Ponle un código (ej. VERANO20)');
    if (value == null || value <= 0) return _snack('Pon un valor válido');
    if (_percentage && value > 100) {
      return _snack('El porcentaje no puede ser mayor a 100');
    }

    final o = widget.original;
    final result = AdminPromotion(
      id: o?.id,
      code: code,
      name: name,
      description: o?.description,
      triggerType: o?.triggerType ?? 'manual',
      discountType: _percentage ? 'percentage' : 'fixed',
      discountValue: value,
      maxDiscountPen: o?.maxDiscountPen,
      isAppOnly: o?.isAppOnly ?? false,
      autoEmit: o?.autoEmit ?? false,
      daysBeforeBirthday: o?.daysBeforeBirthday ?? 0,
      daysAfterBirthday: o?.daysAfterBirthday ?? 0,
      maxUsesPerCustomer: o?.maxUsesPerCustomer ?? 1,
      maxTotalUses: o?.maxTotalUses,
      validFrom: o?.validFrom ?? DateTime.now(),
      validUntil: _presets[_presetIndex].value,
      isActive: _active,
    );
    HapticFeedback.mediumImpact();
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final editing = widget.original != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E0E0E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  editing ? 'Editar promoción' : 'Nueva promoción',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 20),
                _field('Nombre', _nameCtrl, hint: 'Ej. Verano 20%'),
                const SizedBox(height: 14),
                _field('Código', _codeCtrl, hint: 'Ej. VERANO20'),
                const SizedBox(height: 14),
                _label('Tipo de descuento'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _typeChip('Porcentaje %', _percentage,
                        () => setState(() => _percentage = true)),
                    const SizedBox(width: 8),
                    _typeChip('Monto S/', !_percentage,
                        () => setState(() => _percentage = false)),
                  ],
                ),
                const SizedBox(height: 14),
                _field(
                  _percentage ? 'Valor (%)' : 'Valor (S/)',
                  _valueCtrl,
                  hint: _percentage ? 'Ej. 20' : 'Ej. 15',
                  number: true,
                ),
                const SizedBox(height: 14),
                _label('Vence'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < _presets.length; i++)
                      _typeChip(_presets[i].label, _presetIndex == i,
                          () => setState(() => _presetIndex = i)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Promoción activa',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Switch.adaptive(
                        value: _active,
                        activeThumbColor: gold,
                        onChanged: (v) {
                          HapticFeedback.lightImpact();
                          setState(() => _active = v);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                PremiumPressable(
                  onTap: _save,
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F3EC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      editing ? 'Guardar cambios' : 'Crear promoción',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: -0.2,
                      ),
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

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white.withValues(alpha: 0.45),
          letterSpacing: 1.2,
        ),
      );

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    bool number = false,
  }) {
    final gold = context.primaryGold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          cursorColor: gold,
          keyboardType: number
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            filled: true,
            fillColor: const Color(0xFF141414),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: gold.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _typeChip(String label, bool active, VoidCallback onTap) {
    final gold = context.primaryGold;
    final onAccent = premiumOnAccent(gold);
    return PremiumPressable(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? gold : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? gold : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: active ? onAccent : Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
