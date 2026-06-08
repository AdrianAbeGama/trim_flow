import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/reservation_ticket_card.dart';
import 'package:core/core.dart';

class ReservationSuccessView extends StatefulWidget {
  final Reservation reservation;
  final VoidCallback onGoToProfile;

  const ReservationSuccessView({
    super.key,
    required this.reservation,
    required this.onGoToProfile,
  });

  @override
  State<ReservationSuccessView> createState() => _ReservationSuccessViewState();
}

class _ReservationSuccessViewState extends State<ReservationSuccessView> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareReservationImage(BuildContext context) async {
    try {
      // Captura un ticket SIN botones (limpio) para compartir.
      final image = await _screenshotController.captureFromWidget(
        ReservationTicketCard(reservation: widget.reservation),
        context: context,
        pixelRatio: 3,
        delay: const Duration(milliseconds: 50),
      );
      final directory = await getTemporaryDirectory();
      final imageFile = File('${directory.path}/reserva_trimflow.png');
      await imageFile.writeAsBytes(image);
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(imageFile.path)]);
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
                      BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 40),
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ReservationTicketCard(
              reservation: widget.reservation,
              onTapQr: () => _showZoomedQR(context),
              onViewAppointment: widget.onGoToProfile,
              onShare: () => _shareReservationImage(context),
            ),
          ),
        ),
      ),
    );
  }
}
