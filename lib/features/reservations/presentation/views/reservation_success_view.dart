import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:core/core.dart';

class ReservationSuccessView extends StatefulWidget {
  final Reservation reservation;
  final VoidCallback onGoHome;

  const ReservationSuccessView({
    super.key,
    required this.reservation,
    required this.onGoHome,
  });

  @override
  State<ReservationSuccessView> createState() => _ReservationSuccessViewState();
}

class _ReservationSuccessViewState extends State<ReservationSuccessView> {
  late ConfettiController _confettiController;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _shareReservationImage() async {
    try {
      final image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 50),
      );
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imageFile = File('${directory.path}/reserva_trimflow.png');
        await imageFile.writeAsBytes(image);

        // ignore: deprecated_member_use
        await Share.shareXFiles([XFile(imageFile.path)]);
      }
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  void _showZoomedQR(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black.withValues(alpha: 0.95),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Hero(
                tag: 'qr_zoom',
                child: Container(
                  width: 300,
                  height: 300,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.1),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: 'TF-${widget.reservation.id}',
                    version: QrVersions.auto,
                    size: 240,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const Spacer(),
                    
                    // Ticket Capturable
                    Screenshot(
                      controller: _screenshotController,
                      child: Container(
                        color: Colors.black,
                        child: _buildJaggedTicket(context),
                      ),
                    ),

                    const Spacer(),

                    // Botones Lado a Lado
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _shareReservationImage,
                            icon: const Icon(Icons.ios_share_rounded, size: 18),
                            label: const Text('COMPARTIR', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white10),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onGoHome,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryGold,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: const Text('INICIO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [context.primaryGold, Colors.white],
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJaggedTicket(BuildContext context) {
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
                color: context.primaryGold,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            const Text(
              'RESERVA CONFIRMADA',
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: 24),
            
            _buildDetailRow('FECHA', DateFormat("dd / MM / yyyy").format(widget.reservation.date!)),
            const SizedBox(height: 12),
            _buildDetailRow('HORA', widget.reservation.time ?? '--:--'),
            const SizedBox(height: 12),
            _buildDetailRow('BARBERO', widget.reservation.professional?.name ?? 'MÁXIMA DISPONIBILIDAD'),
            
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SERVICIOS', style: TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 6),
                ...widget.reservation.services.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.name, style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('S/ ${s.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    ],
                  ),
                )),
              ],
            ),

            const SizedBox(height: 20),
            _buildDashedLine(),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900)),
                Text(
                  'S/ ${widget.reservation.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(color: context.primaryGold, fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),

            const SizedBox(height: 36),

            // QR Centrado y con Marco Premium
            _buildQRWithFrame(context),
            
            const SizedBox(height: 20),
            Builder(
              builder: (context) {
                final idStr = (widget.reservation.id ?? "").toUpperCase();
                final displayId = idStr.length > 8 ? idStr.substring(0, 8) : idStr;
                return Text(
                  'TF-$displayId',
                  style: const TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRWithFrame(BuildContext context) {
    return GestureDetector(
      onTap: () => _showZoomedQR(context),
      child: Hero(
        tag: 'qr_zoom',
        child: SizedBox(
          width: 150, 
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // El QR con padding para que no toque las esquinas
              Container(
                padding: const EdgeInsets.all(8), // Padding reducido para estar más cerca del marco
                child: QrImageView(
                  data: 'TF-${widget.reservation.id}',
                  version: QrVersions.auto,
                  size: 100.0,
                  padding: EdgeInsets.zero,
                ),
              ),
              // Marco de esquinas (L) más grande que el QR
              Positioned.fill(
                child: CustomPaint(
                  painter: QRCornersPainter(color: context.primaryGold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        Text(value.toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildDashedLine() {
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

    // Ajustado para dejar aire (padding) entre el QR y el marco
    const double margin = 1.0; 
    const double len = 24.0; // Esquinas un poco más largas
    
    final r = Rect.fromLTWH(margin, margin, size.width - 2 * margin, size.height - 2 * margin);

    canvas.drawPath(Path()..moveTo(r.left, r.top + len)..lineTo(r.left, r.top)..lineTo(r.left + len, r.top), paint);
    canvas.drawPath(Path()..moveTo(r.right - len, r.top)..lineTo(r.right, r.top)..lineTo(r.right, r.top + len), paint);
    canvas.drawPath(Path()..moveTo(r.left, r.bottom - len)..lineTo(r.left, r.bottom)..lineTo(r.left + len, r.bottom), paint);
    canvas.drawPath(Path()..moveTo(r.right - len, r.bottom)..lineTo(r.right, r.bottom)..lineTo(r.right, r.bottom - len), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
