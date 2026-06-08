import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui'; // For ImageFilter
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:core/core.dart';

class ProfileTicketModal extends StatefulWidget {
  final Reservation record;
  const ProfileTicketModal({super.key, required this.record});

  static void show(BuildContext context, Reservation record) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => ProfileTicketModal(record: record),
    );
  }

  @override
  State<ProfileTicketModal> createState() => _ProfileTicketModalState();
}

class _ProfileTicketModalState extends State<ProfileTicketModal> {
  final ScreenshotController _screenshotController = ScreenshotController();

  String _safeId(String? rawId) {
    final id = (rawId ?? 'MOCK').toUpperCase();
    return 'TF-${id.substring(0, min(8, id.length))}';
  }

  Future<void> _shareTicket() async {
    try {
      final image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
      );
      if (image == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ticket_trimflow_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(image);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: '', // strictly image-only
        ),
      );
    } catch (e) {
      debugPrint('Error sharing ticket: $e');
    }
  }

  Future<void> _downloadTicket() async {
    try {
      final image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
      );
      if (image == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final ticketId = _safeId(widget.record.id);
      final file = File('${dir.path}/$ticketId.png');
      await file.writeAsBytes(image);
      // Removed SnackBar toast as requested by the user
    } catch (e) {
      debugPrint('Error downloading ticket: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketId = _safeId(widget.record.id);
    final dateStr = widget.record.date != null
        ? DateFormat("dd / MM / yyyy").format(widget.record.date!)
        : '—';
    final centerName = widget.record.center?.name ?? 'Sede Principal';
    final professionalName = widget.record.professional?.name ?? 'Máxima Disponibilidad';
    final basePrice = widget.record.services.fold(0.0, (sum, s) => sum + s.price);
    final isDiscounted = widget.record.totalPrice < basePrice && basePrice > 0;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: SingleChildScrollView(
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating Jagged White Ticket Container (Compact size, splash floating vibe)
                Stack(
                  children: [
                    Screenshot(
                      controller: _screenshotController,
                      child: Container(
                        width: min(MediaQuery.of(context).size.width - 48, 320),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipPath(
                          clipper: TicketClipper(),
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            // Checked Circle Gold Icon
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.primaryGold,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'RESERVA CONFIRMADA',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              centerName.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black38,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Detail Rows
                            _buildDetailRow('FECHA', dateStr),
                            const SizedBox(height: 10),
                            _buildDetailRow('HORA', widget.record.time ?? '--:--'),
                            const SizedBox(height: 10),
                            _buildDetailRow('BARBERO', professionalName),
                            const SizedBox(height: 16),

                            // Services list
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SERVICIOS',
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ...widget.record.services.map(
                                  (s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            s.name,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'S/ ${s.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            _buildDashedLine(),
                            const SizedBox(height: 16),

                            // Price Calculation
                            if (isDiscounted) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'SUBTOTAL',
                                    style: TextStyle(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'S/ ${basePrice.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'DESCUENTO FIDELIDAD (50%)',
                                    style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '- 50%',
                                    style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildDashedLine(),
                              const SizedBox(height: 12),
                            ],

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TOTAL',
                                  style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  'S/ ${widget.record.totalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: context.primaryGold,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Premium Corner-Framed QR Code
                            _buildQRWithFrame(context, ticketId),
                            const SizedBox(height: 12),
                            Text(
                              ticketId,
                              style: const TextStyle(
                                color: Colors.black26,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.black54,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
                const SizedBox(height: 20),

                // Action buttons underneath (Sharing & Downloading)
                SizedBox(
                  width: min(MediaQuery.of(context).size.width - 48, 320),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.ios_share_rounded,
                              label: 'COMPARTIR',
                              onTap: _shareTicket,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.file_download_rounded,
                              label: 'DESCARGAR',
                              onTap: _downloadTicket,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black38,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value.toUpperCase(),
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return Row(
      children: List.generate(
        28,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : Colors.black12,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildQRWithFrame(BuildContext context, String ticketId) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            child: QrImageView(
              data: ticketId,
              version: QrVersions.auto,
              size: 85.0,
              padding: EdgeInsets.zero,
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: QRCornersPainter(color: context.primaryGold),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: context.primaryGold,
        side: BorderSide(color: context.primaryGold.withValues(alpha: 0.35)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: const Color(0xFF0F0F0F),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
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
    const double notchRadius = 10.0;
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
      ..strokeWidth = 2.5
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
