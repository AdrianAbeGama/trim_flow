import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/settings/ticket_style.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';
import 'package:trim_flow/features/products/presentation/widgets/barcode_widget.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/reservation_ticket_card.dart'
    show TicketClipper;

/// Comprobante de pedido enriquecido (se muestra directo al abrir un pedido):
/// línea de tiempo del estado, sede de recojo, método de pago, productos con
/// descripción, total y código de barras. Ticket roto, blanco u oscuro según
/// `TicketStyle`.
class OrderTicketCard extends StatelessWidget {
  const OrderTicketCard({super.key, required this.order, this.customerName});

  final ProductOrder order;

  /// Nombre del cliente (vista del barbero). En la app del cliente es null.
  final String? customerName;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: TicketStyle.dark,
      builder: (context, dark, _) => _ticket(context, dark),
    );
  }

  Widget _ticket(BuildContext context, bool dark) {
    final gold = context.primaryGold;
    final cancelled = order.status == OrderStatus.cancelled;

    final bg = dark ? const Color(0xFF1A1A1A) : Colors.white;
    final textPrimary = dark ? Colors.white : Colors.black;
    final textMuted = dark ? Colors.white.withValues(alpha: 0.5) : Colors.black54;
    final label = dark ? Colors.white.withValues(alpha: 0.4) : Colors.black38;
    final divider = dark ? Colors.white.withValues(alpha: 0.12) : Colors.black12;
    final pending = dark ? Colors.white.withValues(alpha: 0.22) : Colors.black26;
    final folio = dark ? Colors.white.withValues(alpha: 0.3) : Colors.black26;
    const accentCancel = Color(0xFFCF6679);

    return ClipPath(
      clipper: TicketClipper(),
      child: Container(
        width: double.infinity,
        color: bg,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cancelled ? accentCancel : (dark ? gold.withValues(alpha: 0.14) : gold),
                shape: BoxShape.circle,
                border: Border.all(color: dark && !cancelled ? gold.withValues(alpha: 0.45) : Colors.white, width: 2),
              ),
              child: Icon(cancelled ? Icons.close_rounded : Icons.check_rounded, color: cancelled ? Colors.white : (dark ? gold : Colors.white), size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              cancelled ? 'PEDIDO CANCELADO' : 'COMPROBANTE DE PEDIDO',
              style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            Text(order.code, style: TextStyle(color: label, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 24),
            if (cancelled)
              _cancelNote(textMuted)
            else
              _timeline(gold, textPrimary, pending, divider),
            const SizedBox(height: 22),
            _dashedLine(divider),
            const SizedBox(height: 18),
            _infoRow(gold, Icons.event_rounded, 'FECHA Y HORA', _cap(DateFormat("EEEE d 'de' MMM · HH:mm", 'es').format(order.createdAt)), label, textPrimary, textMuted),
            const SizedBox(height: 16),
            if (customerName != null && customerName!.trim().isNotEmpty) ...[
              _infoRow(gold, Icons.person_rounded, 'CLIENTE', customerName!, label, textPrimary, textMuted),
              const SizedBox(height: 16),
            ],
            _infoRow(gold, Icons.storefront_rounded, 'SEDE DE RECOJO', order.branchName, label, textPrimary, textMuted, sub: order.pickupAddress),
            const SizedBox(height: 16),
            _infoRow(gold, Icons.payments_rounded, 'MÉTODO DE PAGO', order.paymentMethod.label, label, textPrimary, textMuted),
            const SizedBox(height: 18),
            _dashedLine(divider),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PRODUCTOS', style: TextStyle(color: label, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.product.name}',
                                    style: TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('S/ ${(item.product.price * item.quantity).toStringAsFixed(2)}', style: TextStyle(color: textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            if (item.product.description.trim().isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                item.product.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: textMuted, fontSize: 11.5, height: 1.35),
                              ),
                            ],
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _dashedLine(divider),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL', style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w900)),
                Text('S/ ${order.total.toStringAsFixed(2)}', style: TextStyle(color: gold, fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => showBarcodeZoom(context, order.code),
              child: dark
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: BarcodeWidget(code: order.code),
                    )
                  : BarcodeWidget(code: order.code),
            ),
            const SizedBox(height: 14),
            Text('TOCA EL CÓDIGO PARA AMPLIAR', style: TextStyle(color: folio, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }

  int get _doneCount {
    switch (order.status) {
      case OrderStatus.pendingPayment:
        return 1;
      case OrderStatus.paid:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.completed:
        return 4;
      case OrderStatus.cancelled:
        return 0;
    }
  }

  Widget _timeline(Color gold, Color textPrimary, Color pending, Color lineColor) {
    const labels = ['Pedido', 'Pagado', 'Listo', 'Recogido'];
    final done = _doneCount;
    return Row(
      children: List.generate(labels.length, (i) {
        final isDone = i < done;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Container(height: 2, color: i == 0 ? Colors.transparent : (i < done ? gold : lineColor))),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDone ? gold : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDone ? gold : pending, width: 2),
                    ),
                    child: isDone ? Icon(Icons.check_rounded, color: premiumOnAccent(gold), size: 13) : null,
                  ),
                  Expanded(child: Container(height: 2, color: i == labels.length - 1 ? Colors.transparent : (i < done - 1 ? gold : lineColor))),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                labels[i].toUpperCase(),
                style: TextStyle(
                  color: isDone ? textPrimary : pending,
                  fontSize: 8.5,
                  fontWeight: isDone ? FontWeight.w900 : FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _cancelNote(Color textMuted) {
    final reason = order.cancellationReason;
    return Column(
      children: [
        Text(
          'Este pedido fue cancelado y no será preparado.',
          textAlign: TextAlign.center,
          style: TextStyle(color: textMuted, fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.4),
        ),
        if (reason != null && reason.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Motivo: $reason', textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }

  Widget _infoRow(Color gold, IconData icon, String labelTxt, String value, Color labelColor, Color valueColor, Color subColor, {String? sub}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: gold, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(labelTxt, style: TextStyle(color: labelColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 3),
              Text(value, style: TextStyle(color: valueColor, fontSize: 13.5, fontWeight: FontWeight.w800, height: 1.25)),
              if (sub != null && sub.trim().isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(sub, style: TextStyle(color: subColor, fontSize: 11.5, fontWeight: FontWeight.w500)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _cap(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  Widget _dashedLine(Color color) {
    return Row(
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : color,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
