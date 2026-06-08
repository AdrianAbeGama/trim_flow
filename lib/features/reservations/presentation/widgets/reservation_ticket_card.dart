import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:core/core.dart';

/// Ticket de reserva (recibo blanco con borde dentado + QR). Compartido entre
/// la vista previa del paso 5 (`isPreview: true`, sin QR/sello) y la pantalla
/// de exito (`isPreview: false`, con sello, QR y folio).
class ReservationTicketCard extends StatelessWidget {
  const ReservationTicketCard({
    super.key,
    required this.reservation,
    this.isPreview = false,
    this.onTapQr,
    this.onViewAppointment,
    this.onShare,
  });

  final Reservation reservation;
  final bool isPreview;
  final VoidCallback? onTapQr;
  final VoidCallback? onViewAppointment;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final dateStr = reservation.date != null
        ? DateFormat('dd / MM / yyyy').format(reservation.date!)
        : '--/--/----';

    return ClipPath(
      clipper: TicketClipper(),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isPreview) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              isPreview ? 'RESUMEN DE TU RESERVA' : 'RESERVA CONFIRMADA',
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: 24),
            _detailRow('FECHA', dateStr),
            const SizedBox(height: 12),
            _detailRow('HORA', reservation.time ?? '--:--'),
            const SizedBox(height: 12),
            _detailRow('BARBERO', reservation.professional?.name ?? 'MÁXIMA DISPONIBILIDAD'),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SERVICIO', style: TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 6),
                ...reservation.services.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(s.name, style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                          Text('S/ ${s.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                        ],
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 20),
            _dashedLine(),
            const SizedBox(height: 20),
            _totals(context),
            if (!isPreview) ...[
              const SizedBox(height: 36),
              _qrWithFrame(context),
              const SizedBox(height: 20),
              Builder(
                builder: (context) {
                  final idStr = (reservation.id ?? '').toUpperCase();
                  final displayId = idStr.length > 8 ? idStr.substring(0, 8) : idStr;
                  return Text(
                    'TF-$displayId',
                    style: const TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                  );
                },
              ),
              if (onViewAppointment != null || onShare != null) ...[
                const SizedBox(height: 22),
                Row(
                  children: [
                    if (onViewAppointment != null)
                      Expanded(
                        child: _TicketButton(
                          label: 'VER MI CITA',
                          icon: Icons.person_rounded,
                          filled: true,
                          accent: gold,
                          onTap: onViewAppointment!,
                        ),
                      ),
                    if (onViewAppointment != null && onShare != null) const SizedBox(width: 10),
                    if (onShare != null)
                      Expanded(
                        child: _TicketButton(
                          label: 'COMPARTIR',
                          icon: Icons.ios_share_rounded,
                          filled: false,
                          accent: gold,
                          onTap: onShare!,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _totals(BuildContext context) {
    final gold = context.primaryGold;
    final basePrice = reservation.services.fold(0.0, (sum, item) => sum + item.price);
    final isDiscountApplied = reservation.totalPrice < basePrice;

    return Column(
      children: [
        if (isDiscountApplied) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SUBTOTAL', style: TextStyle(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('S/ ${basePrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('DESCUENTO FIDELIDAD (50%)', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('- S/ ${(basePrice * 0.5).toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('TOTAL', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900)),
            Text('S/ ${reservation.totalPrice.toStringAsFixed(2)}', style: TextStyle(color: gold, fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    );
  }

  Widget _qrWithFrame(BuildContext context) {
    return GestureDetector(
      onTap: onTapQr,
      child: Hero(
        tag: 'qr_zoom',
        child: SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: QrImageView(
                  data: 'TF-${reservation.id}',
                  version: QrVersions.auto,
                  size: 100.0,
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(
                width: 116,
                height: 116,
                child: CustomPaint(painter: QRCornersPainter(color: context.primaryGold)),
              ),
            ],
          ),
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

class _TicketButton extends StatelessWidget {
  const _TicketButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? premiumOnAccent(accent) : Colors.black;
    return PremiumPressable(
      pressedScale: 0.96,
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: filled ? null : Border.all(color: Colors.black.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 11.5, letterSpacing: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double triangleHeight = 6.0;
    const double triangleWidth = 10.0;
    const double notchRadius = 12.0;
    final double dividerPos = size.height * 0.65;

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    path.lineTo(size.width, dividerPos - notchRadius);
    path.arcToPoint(
      Offset(size.width, dividerPos + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - triangleHeight);

    for (double i = size.width; i > 0; i -= triangleWidth) {
      path.lineTo(i - triangleWidth / 2, size.height);
      path.lineTo(i - triangleWidth, size.height - triangleHeight);
    }

    path.lineTo(0, dividerPos + notchRadius);
    path.arcToPoint(
      Offset(0, dividerPos - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class QRCornersPainter extends CustomPainter {
  final Color color;
  QRCornersPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    const double margin = 1.0;
    const double len = 18.0;

    final r = Rect.fromLTWH(margin, margin, size.width - 2 * margin, size.height - 2 * margin);

    canvas.drawPath(Path()..moveTo(r.left, r.top + len)..lineTo(r.left, r.top)..lineTo(r.left + len, r.top), paint);
    canvas.drawPath(Path()..moveTo(r.right - len, r.top)..lineTo(r.right, r.top)..lineTo(r.right, r.top + len), paint);
    canvas.drawPath(Path()..moveTo(r.left, r.bottom - len)..lineTo(r.left, r.bottom)..lineTo(r.left + len, r.bottom), paint);
    canvas.drawPath(Path()..moveTo(r.right - len, r.bottom)..lineTo(r.right, r.bottom)..lineTo(r.right, r.bottom - len), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
