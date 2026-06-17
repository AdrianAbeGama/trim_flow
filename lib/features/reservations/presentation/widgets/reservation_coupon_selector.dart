import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/profile/domain/models/customer_coupon.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_bloc.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_event.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_state.dart';

/// Selector de cupón en el paso de confirmar la reserva. Solo aparece si el
/// cliente tiene cupones usables en este tenant (get_my_coupons).
class ReservationCouponSelector extends StatelessWidget {
  const ReservationCouponSelector({super.key, required this.state});

  final ReservationState state;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final selected = state.selectedCoupon;
    if (state.availableCoupons.isEmpty && selected == null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected != null
            ? gold.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected != null
              ? gold.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: selected == null
          ? _empty(context, gold)
          : _applied(context, gold, selected),
    );
  }

  Widget _empty(BuildContext context, Color gold) {
    final n = state.availableCoupons.length;
    return PremiumPressable(
      onTap: () => _openSheet(context),
      child: Row(
        children: [
          Icon(Icons.local_offer_rounded, color: gold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aplicar un cupón',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text('$n disponible${n == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Colors.white38, size: 20),
        ],
      ),
    );
  }

  Widget _applied(BuildContext context, Color gold, CustomerCoupon c) {
    final discount = state.couponDiscount;
    return Row(
      children: [
        Icon(Icons.verified_rounded, color: gold, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
              Text(
                'Cupón ${c.discountLabel}${discount > 0 ? ' · ahorras S/ ${discount.toStringAsFixed(2)}' : ''}',
                style: GoogleFonts.inter(
                    color: gold, fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        PremiumPressable(
          pressedScale: 0.85,
          onTap: () {
            HapticFeedback.lightImpact();
            context
                .read<ReservationBloc>()
                .add(const ReservationEvent.selectCoupon(null));
          },
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded,
                color: Colors.white70, size: 16),
          ),
        ),
      ],
    );
  }

  void _openSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final bloc = context.read<ReservationBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CouponSheet(
        coupons: state.availableCoupons,
        selected: state.selectedCoupon,
        onPick: (c) {
          bloc.add(ReservationEvent.selectCoupon(c));
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CouponSheet extends StatelessWidget {
  const _CouponSheet({
    required this.coupons,
    required this.selected,
    required this.onPick,
  });

  final List<CustomerCoupon> coupons;
  final CustomerCoupon? selected;
  final void Function(CustomerCoupon?) onPick;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF131313),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text('Tus cupones',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  _row(context, gold, null),
                  for (final c in coupons) _row(context, gold, c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, Color gold, CustomerCoupon? c) {
    final isSel =
        (c == null && selected == null) || (c != null && selected?.id == c.id);
    final title = c?.name ?? 'Sin cupón';
    final subtitle = c == null
        ? 'Pagar precio normal'
        : '${c.discountLabel} · vence ${DateFormat('d MMM', 'es').format(c.validUntil)}';
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: () {
        HapticFeedback.selectionClick();
        onPick(c);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSel ? gold.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(c == null ? Icons.block_rounded : Icons.local_offer_rounded,
                size: 18,
                color: isSel ? gold : Colors.white.withValues(alpha: 0.5)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight:
                              isSel ? FontWeight.w800 : FontWeight.w600,
                          color: isSel
                              ? gold
                              : Colors.white.withValues(alpha: 0.9))),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.45))),
                ],
              ),
            ),
            if (isSel) Icon(Icons.check_rounded, size: 19, color: gold),
          ],
        ),
      ),
    );
  }
}
