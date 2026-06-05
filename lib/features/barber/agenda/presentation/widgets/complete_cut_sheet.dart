import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/domain/repositories/agenda_repository.dart';

class CompleteResult {
  final double amount;
  final String? couponCode;
  const CompleteResult({required this.amount, this.couponCode});
}

/// Sheet para completar el corte: muestra el monto y permite aplicar un cupon
/// usable del cliente (descuento real). Devuelve un [CompleteResult].
class CompleteCutSheet extends StatefulWidget {
  const CompleteCutSheet({super.key, required this.appointment});

  final AgendaAppointment appointment;

  @override
  State<CompleteCutSheet> createState() => _CompleteCutSheetState();
}

class _CompleteCutSheetState extends State<CompleteCutSheet> {
  List<AgendaCoupon> _coupons = const [];
  AgendaCoupon? _selected;
  bool _loading = true;

  double get _basePrice => widget.appointment.priceAtBooking ?? 0;
  double get _discount => _selected?.discountFor(_basePrice) ?? 0;
  double get _total => (_basePrice - _discount).clamp(0, _basePrice).toDouble();

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    final cid = widget.appointment.customerId;
    if (cid == null || cid.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final list = await getIt<AgendaRepository>().fetchUsableCoupons(customerId: cid);
      if (mounted) {
        setState(() {
          _coupons = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _confirm() {
    HapticFeedback.mediumImpact();
    Navigator.pop(
      context,
      CompleteResult(amount: _total, couponCode: _selected?.code),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
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
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 18),
            Text('Completar corte', style: GoogleFonts.inter(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
            const SizedBox(height: 4),
            Text(
              widget.appointment.serviceName ?? 'Servicio',
              style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 18),
            if (_loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: gold)),
                    const SizedBox(width: 10),
                    Text('Buscando cupones...', style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            else if (_coupons.isNotEmpty) ...[
              Text('CUPÓN (OPCIONAL)', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _coupons
                    .map((c) => _CouponChip(
                          coupon: c,
                          selected: _selected?.code == c.code,
                          onTap: () => setState(() => _selected = _selected?.code == c.code ? null : c),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 18),
            ],
            _row('Servicio', 'S/ ${_basePrice.toStringAsFixed(2)}', dim: true),
            if (_selected != null) ...[
              const SizedBox(height: 6),
              _row('Cupón ${_selected!.label}', '- S/ ${_discount.toStringAsFixed(2)}', accent: true),
            ],
            const SizedBox(height: 10),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                Text('S/ ${_total.toStringAsFixed(2)}', style: GoogleFonts.inter(color: gold, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.6)),
              ],
            ),
            const SizedBox(height: 20),
            PremiumPressable(
              pressedScale: 0.97,
              onTap: _confirm,
              child: Container(
                width: double.infinity,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: premiumOnAccent(gold), size: 18),
                    const SizedBox(width: 8),
                    Text('COMPLETAR CORTE', style: GoogleFonts.inter(color: premiumOnAccent(gold), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool dim = false, bool accent = false}) {
    final gold = context.primaryGold;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(color: accent ? gold : Colors.white.withValues(alpha: dim ? 0.5 : 0.8), fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Text(value, style: GoogleFonts.inter(color: accent ? gold : Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _CouponChip extends StatelessWidget {
  const _CouponChip({required this.coupon, required this.selected, required this.onTap});

  final AgendaCoupon coupon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return PremiumPressable(
      pressedScale: 0.96,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? gold.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? gold : Colors.white.withValues(alpha: 0.1), width: selected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(7)),
              child: Text(coupon.label, style: GoogleFonts.inter(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 8),
            Text(
              coupon.name,
              style: GoogleFonts.inter(color: selected ? Colors.white : Colors.white.withValues(alpha: 0.75), fontSize: 12, fontWeight: FontWeight.w700),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_circle_rounded, size: 15, color: gold),
            ],
          ],
        ),
      ),
    );
  }
}
