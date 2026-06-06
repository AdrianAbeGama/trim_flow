import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/admin/domain/models/admin_promotion.dart';
import 'package:trim_flow/features/admin/presentation/widgets/admin_primitives.dart';

typedef _Preset = ({String label, DateTime? value});

/// Abre el formulario de promoción. `onSubmit` ejecuta el guardado; el sheet
/// muestra carga y solo se cierra (true) tras éxito.
Future<bool?> showPromotionForm(
  BuildContext context, {
  AdminPromotion? promo,
  required Future<void> Function(AdminPromotion) onSubmit,
}) {
  return showAdminSheet<bool>(
      context, _PromotionForm(original: promo, onSubmit: onSubmit));
}

class _PromotionForm extends StatefulWidget {
  const _PromotionForm({this.original, required this.onSubmit});

  final AdminPromotion? original;
  final Future<void> Function(AdminPromotion) onSubmit;

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
  bool _saving = false;

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

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final code = _codeCtrl.text.trim().toUpperCase().replaceAll(' ', '');
    final value = double.tryParse(_valueCtrl.text.trim().replaceAll(',', '.'));
    if (name.isEmpty) return adminSnack(context, 'Ponle un nombre a la promoción');
    if (code.isEmpty) return adminSnack(context, 'Ponle un código (ej. VERANO20)');
    if (value == null || value <= 0) return adminSnack(context, 'Pon un valor válido');
    if (_percentage && value > 100) {
      return adminSnack(context, 'El porcentaje no puede ser mayor a 100');
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
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    try {
      await widget.onSubmit(result);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      adminSnack(context, 'No se pudo guardar. Revisa el código (no repetido).');
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final editing = widget.original != null;
    return AdminSheetScaffold(
      title: editing ? 'Editar promoción' : 'Nueva promoción',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminTextField(
              controller: _nameCtrl, label: 'Nombre', hint: 'Ej. Verano 20%'),
          const SizedBox(height: 14),
          AdminTextField(
              controller: _codeCtrl, label: 'Código', hint: 'Ej. VERANO20'),
          const SizedBox(height: 14),
          _label('Tipo de descuento'),
          const SizedBox(height: 8),
          Row(
            children: [
              AdminChoiceChip(
                label: 'Porcentaje %',
                selected: _percentage,
                onTap: () => setState(() => _percentage = true),
              ),
              const SizedBox(width: 8),
              AdminChoiceChip(
                label: 'Monto S/',
                selected: !_percentage,
                onTap: () => setState(() => _percentage = false),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AdminTextField(
            controller: _valueCtrl,
            label: _percentage ? 'Valor (%)' : 'Valor (S/)',
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
                AdminChoiceChip(
                  label: _presets[i].label,
                  selected: _presetIndex == i,
                  onTap: () => setState(() => _presetIndex = i),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
          AdminPrimaryButton(
            label: editing ? 'Guardar cambios' : 'Crear promoción',
            loading: _saving,
            onTap: _save,
          ),
        ],
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
}
