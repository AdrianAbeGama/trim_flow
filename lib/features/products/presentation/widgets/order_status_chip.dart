import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';

Color orderStatusColor(OrderStatus status, Color gold) {
  switch (status) {
    case OrderStatus.pendingPayment:
      return const Color(0xFFE0A458);
    case OrderStatus.paid:
      return gold;
    case OrderStatus.ready:
      return const Color(0xFF6FA8DC);
    case OrderStatus.completed:
      return const Color(0xFF6FAE8A);
    case OrderStatus.cancelled:
      return const Color(0xFFCF6679);
  }
}

IconData orderStatusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.pendingPayment:
      return Icons.schedule_rounded;
    case OrderStatus.paid:
      return Icons.payments_rounded;
    case OrderStatus.ready:
      return Icons.inventory_2_rounded;
    case OrderStatus.completed:
      return Icons.check_circle_rounded;
    case OrderStatus.cancelled:
      return Icons.cancel_rounded;
  }
}

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({
    super.key,
    required this.status,
    required this.gold,
    this.short = false,
  });

  final OrderStatus status;
  final Color gold;
  final bool short;

  @override
  Widget build(BuildContext context) {
    final color = orderStatusColor(status, gold);
    final label = short ? status.short : status.label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(orderStatusIcon(status), color: color, size: 11),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

/// Pequeña etiqueta de pago (PAGADO / POR PAGAR).
class OrderPaidTag extends StatelessWidget {
  const OrderPaidTag({super.key, required this.isPaid});

  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    final color = isPaid ? const Color(0xFF6FAE8A) : const Color(0xFFE0A458);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          isPaid ? 'PAGADO' : 'POR PAGAR',
          style: GoogleFonts.inter(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8),
        ),
      ],
    );
  }
}
