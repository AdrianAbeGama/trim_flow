import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trim_flow/core/settings/ticket_style.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/reservation_ticket_card.dart';
import 'package:core/core.dart';

/// Modal de "Ver ticket" — muestra el ticket dark premium compartido
/// (`ReservationTicketCard`) con acciones de compartir y descargar.
class ProfileTicketModal extends StatefulWidget {
  final Reservation record;
  const ProfileTicketModal({super.key, required this.record});

  static void show(BuildContext context, Reservation record) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => ProfileTicketModal(record: _withCatalogPrice(context, record)),
    );
  }

  /// Las citas del backend traen el precio YA pagado (con descuento). Para que
  /// el ticket muestre subtotal → descuento → total, recuperamos el precio de
  /// lista del servicio desde el catálogo y lo usamos como precio original.
  static Reservation _withCatalogPrice(BuildContext context, Reservation r) {
    if (r.services.isEmpty) return r;
    final svc = r.services.first;
    final services = context.read<CatalogBloc>().state.services;
    double? listPrice;
    for (final s in services) {
      if (s.name.toLowerCase() == svc.name.toLowerCase()) {
        listPrice = s.price;
        break;
      }
    }
    if (listPrice == null || listPrice <= r.totalPrice + 0.009) return r;
    return r.copyWith(services: [svc.copyWith(price: listPrice)]);
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
          text: '',
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
    } catch (e) {
      debugPrint('Error downloading ticket: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = min(MediaQuery.of(context).size.width - 48, 340.0);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Screenshot(
                    controller: _screenshotController,
                    child: SizedBox(
                      width: cardWidth,
                      child: ReservationTicketCard(reservation: widget.record),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: TicketStyle.dark,
                        builder: (_, dark, _) => Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: (dark ? Colors.white : Colors.black).withValues(alpha: dark ? 0.10 : 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: (dark ? Colors.white : Colors.black).withValues(alpha: dark ? 0.8 : 0.54),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: cardWidth,
                child: Row(
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
              ),
            ],
          ),
        ),
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
