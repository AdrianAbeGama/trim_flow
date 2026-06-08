import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/reservation_ticket_card.dart'
    show TicketClipper, QRCornersPainter;

/// Recibo blanco (estilo ticket de reserva) para el detalle de un pedido.
class OrderTicketCard extends StatelessWidget {
  const OrderTicketCard({super.key, required this.order});

  final ProductOrder order;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final dateStr = DateFormat('dd / MM / yyyy · HH:mm').format(order.createdAt);
    final cancelled = order.status == OrderStatus.cancelled;

    return ClipPath(
      clipper: TicketClipper(),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cancelled ? const Color(0xFFCF6679) : gold,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(cancelled ? Icons.close_rounded : Icons.check_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              cancelled ? 'PEDIDO CANCELADO' : 'COMPROBANTE DE PEDIDO',
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: 24),
            _detailRow('PEDIDO', order.code),
            const SizedBox(height: 12),
            _detailRow('FECHA', dateStr),
            const SizedBox(height: 12),
            _detailRow('MÉTODO', order.paymentMethod.label),
            const SizedBox(height: 12),
            _detailRow('ESTADO', order.status.label),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PRODUCTOS', style: TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}x ${item.product.name}',
                              style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'S/ ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 20),
            _dashedLine(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900)),
                Text('S/ ${order.total.toStringAsFixed(2)}', style: TextStyle(color: gold, fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: QrImageView(
                      data: order.code,
                      version: QrVersions.auto,
                      size: 100,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(
                    width: 116,
                    height: 116,
                    child: CustomPaint(painter: QRCornersPainter(color: gold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              order.code,
              style: const TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        Flexible(
          child: Text(
            value.toUpperCase(),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _dashedLine() {
    return Row(
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : Colors.black12,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
