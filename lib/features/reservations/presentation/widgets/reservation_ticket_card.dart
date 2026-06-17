import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trim_flow/core/settings/ticket_style.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:core/core.dart';

/// Ticket de reserva. Estilo blanco (recibo de papel) por defecto o negro
/// (dark premium), segun la preferencia guardada en `TicketStyle`. Compartido
/// entre la vista previa del paso 5 (`isPreview: true`), la pantalla de exito y
/// el modal de "Ver ticket". Los botones solo se muestran si se pasan callbacks.
class ReservationTicketCard extends StatelessWidget {
  const ReservationTicketCard({
    super.key,
    required this.reservation,
    this.isPreview = false,
    this.onTapQr,
    this.onViewAppointment,
    this.onShare,
    this.onDownload,
    this.couponName,
    this.couponDiscount,
    this.finalPrice,
  });

  final Reservation reservation;
  final bool isPreview;
  final VoidCallback? onTapQr;
  final VoidCallback? onViewAppointment;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;

  /// Datos del cupón aplicado (si hubo). Si [couponName] es null no hay cupón.
  final String? couponName;
  final double? couponDiscount;
  final double? finalPrice;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: TicketStyle.dark,
      builder: (context, dark, _) => _ticket(context, dark),
    );
  }

  Widget _ticket(BuildContext context, bool dark) {
    final gold = context.primaryGold;
    final textPrimary = dark ? Colors.white : Colors.black;
    final textMuted = dark ? Colors.white.withValues(alpha: 0.55) : Colors.black54;
    final labelColor = dark ? Colors.white.withValues(alpha: 0.4) : Colors.black38;
    final dividerColor = dark ? Colors.white.withValues(alpha: 0.12) : Colors.black12;
    final folioColor = dark ? Colors.white.withValues(alpha: 0.3) : Colors.black26;
    final dateStr = reservation.date != null
        ? DateFormat('dd / MM / yyyy').format(reservation.date!)
        : '--/--/----';
    final center = reservation.center;
    final hasButtons = onViewAppointment != null || onShare != null || onDownload != null;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isPreview) ...[
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: dark ? gold.withValues(alpha: 0.14) : gold,
              shape: BoxShape.circle,
              border: Border.all(color: dark ? gold.withValues(alpha: 0.45) : Colors.white, width: dark ? 1.5 : 2),
            ),
            child: Icon(Icons.check_rounded, color: dark ? gold : Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          isPreview ? 'RESUMEN DE TU RESERVA' : 'RESERVA CONFIRMADA',
          style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        if (center != null && center.name.trim().isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            center.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(color: labelColor, fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ],
        const SizedBox(height: 24),
        _detailRow('FECHA', dateStr, labelColor, textPrimary),
        const SizedBox(height: 12),
        _detailRow('HORA', reservation.time ?? '--:--', labelColor, textPrimary),
        const SizedBox(height: 12),
        _detailRow('BARBERO', reservation.professional?.name ?? 'MÁXIMA DISPONIBILIDAD', labelColor, textPrimary),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SERVICIO', style: TextStyle(color: labelColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 6),
              ...reservation.services.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(s.name, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                        Text('S/ ${s.price.toStringAsFixed(2)}', style: TextStyle(color: textMuted, fontSize: 13)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _perforation(dividerColor),
        const SizedBox(height: 20),
        _totals(context, textPrimary, dividerColor),
        if (!isPreview) ...[
          const SizedBox(height: 32),
          _qr(context, dark),
          const SizedBox(height: 18),
          Builder(
            builder: (context) {
              final idStr = (reservation.id ?? '').toUpperCase();
              final displayId = idStr.length > 8 ? idStr.substring(0, 8) : idStr;
              return Text(
                'TF-$displayId',
                style: TextStyle(color: folioColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
              );
            },
          ),
          if (hasButtons) ...[
            const SizedBox(height: 22),
            _buttons(gold, dark),
          ],
        ],
      ],
    );

    // Misma forma para blanco y oscuro (ticket roto + muescas), solo cambia el
    // color de fondo.
    return ClipPath(
      clipper: TicketClipper(),
      child: Container(
        width: double.infinity,
        color: dark ? const Color(0xFF1A1A1A) : Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: content,
      ),
    );
  }

  Widget _buttons(Color gold, bool dark) {
    return Row(
      children: [
        if (onViewAppointment != null)
          Expanded(
            child: _TicketButton(
              label: 'VER MI CITA',
              icon: Icons.person_rounded,
              filled: true,
              accent: gold,
              dark: dark,
              onTap: onViewAppointment!,
            ),
          ),
        if (onShare != null) ...[
          if (onViewAppointment != null) const SizedBox(width: 10),
          Expanded(
            child: _TicketButton(
              label: 'COMPARTIR',
              icon: Icons.ios_share_rounded,
              filled: onViewAppointment == null && onDownload == null,
              accent: gold,
              dark: dark,
              onTap: onShare!,
            ),
          ),
        ],
        if (onDownload != null) ...[
          if (onViewAppointment != null || onShare != null) const SizedBox(width: 10),
          Expanded(
            child: _TicketButton(
              label: 'DESCARGAR',
              icon: Icons.file_download_rounded,
              filled: false,
              accent: gold,
              dark: dark,
              onTap: onDownload!,
            ),
          ),
        ],
      ],
    );
  }

  Widget _totals(BuildContext context, Color textPrimary, Color dividerColor) {
    final gold = context.primaryGold;
    final basePrice =
        reservation.services.fold(0.0, (sum, item) => sum + item.price);
    final total = finalPrice ?? reservation.totalPrice;
    final discount = couponDiscount ?? (basePrice - total);
    final hasDiscount = basePrice > 0 && discount > 0.009;
    const green = Color(0xFF3FA45F);
    final pct = basePrice > 0 ? (discount / basePrice * 100).round() : 0;
    final label = couponName != null
        ? 'CUPÓN · ${couponName!.toUpperCase()}'
        : 'DESCUENTO';

    return Column(
      children: [
        if (hasDiscount) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SUBTOTAL', style: TextStyle(color: textPrimary.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.bold)),
              Text('S/ ${basePrice.toStringAsFixed(2)}', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$label${pct > 0 ? ' ($pct%)' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: green, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text('- S/ ${discount.toStringAsFixed(2)}', style: const TextStyle(color: green, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: dividerColor, height: 1),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TOTAL', style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w900)),
            Text('S/ ${total.toStringAsFixed(2)}', style: TextStyle(color: gold, fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    );
  }

  Widget _qr(BuildContext context, bool dark) {
    final gold = context.primaryGold;
    final qr = SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(dark ? 12 : 8),
            decoration: dark ? BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)) : null,
            child: QrImageView(
              data: 'TF-${reservation.id}',
              version: QrVersions.auto,
              size: dark ? 104 : 100,
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(
            width: dark ? 150 : 116,
            height: dark ? 150 : 116,
            child: CustomPaint(painter: QRCornersPainter(color: gold)),
          ),
        ],
      ),
    );

    if (onTapQr == null) return qr;
    return GestureDetector(
      onTap: onTapQr,
      child: Hero(tag: 'qr_zoom', child: qr),
    );
  }

  Widget _detailRow(String label, String value, Color labelColor, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value.toUpperCase(),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _perforation(Color color) {
    return Row(
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            color: index.isEven ? Colors.transparent : color,
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
    required this.dark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final Color accent;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final outlineFg = dark ? Colors.white : Colors.black;
    final fg = filled ? premiumOnAccent(accent) : outlineFg;
    return PremiumPressable(
      pressedScale: 0.96,
      onTap: onTap,
      child: Container(
        height: 47,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? accent : (dark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent),
          borderRadius: BorderRadius.circular(13),
          border: filled ? null : Border.all(color: outlineFg.withValues(alpha: dark ? 0.16 : 0.18)),
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
