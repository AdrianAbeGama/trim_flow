import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/reviews/domain/models/reviewable_reservation.dart';
import 'package:trim_flow/features/reviews/domain/repositories/reviews_repository.dart';

/// Sheet premium para calificar un corte: estrellas + comentario opcional.
/// Devuelve true si la reseña se envio.
class RateAppointmentSheet extends StatefulWidget {
  const RateAppointmentSheet({super.key, required this.reservation});

  final ReviewableReservation reservation;

  static Future<bool?> show(BuildContext context, ReviewableReservation r) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RateAppointmentSheet(reservation: r),
    );
  }

  @override
  State<RateAppointmentSheet> createState() => _RateAppointmentSheetState();
}

class _RateAppointmentSheetState extends State<RateAppointmentSheet> {
  int _rating = 0;
  final _comment = TextEditingController();
  bool _sending = false;

  static const _labels = [
    '', 'Malo', 'Regular', 'Bueno', 'Muy bueno', 'Excelente'
  ];

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0 || _sending) return;
    HapticFeedback.mediumImpact();
    final overlay = Overlay.of(context, rootOverlay: true);
    final navigator = Navigator.of(context);
    setState(() => _sending = true);
    try {
      await getIt<ReviewsRepository>().submit(
        reservationId: widget.reservation.reservationId,
        rating: _rating,
        comment: _comment.text,
      );
      navigator.pop(true);
      AppToast.showOn(overlay,
          type: AppToastType.success,
          title: '¡Gracias por tu reseña!',
          message: 'Ayuda a otros a elegir su barbero.');
    } catch (e) {
      if (mounted) setState(() => _sending = false);
      AppToast.showOn(overlay,
          type: AppToastType.error, title: 'No se pudo enviar', message: '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final r = widget.reservation;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Califica tu corte',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${r.serviceName} · con ${r.barberName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [for (var i = 1; i <= 5; i++) _star(i, gold)],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: Text(
                    _rating == 0 ? 'Toca las estrellas' : _labels[_rating],
                    key: ValueKey(_rating),
                    style: GoogleFonts.inter(
                      color: _rating == 0 ? Colors.white38 : gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _comment,
                maxLength: 500,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                cursorColor: gold,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Cuéntanos cómo te fue (opcional)',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                  counterText: '',
                  isDense: true,
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: gold, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              PremiumPressable(
                pressedScale: _rating > 0 ? 0.97 : 1,
                onTap: _submit,
                child: AnimatedOpacity(
                  opacity: _rating > 0 ? 1 : 0.4,
                  duration: const Duration(milliseconds: 160),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F3EC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.6, color: Colors.black),
                          )
                        : Text(
                            'ENVIAR RESEÑA',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _star(int i, Color gold) {
    final on = i <= _rating;
    return PremiumPressable(
      pressedScale: 0.85,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _rating = i);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: FaIcon(
          on ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
          color: on ? gold : Colors.white.withValues(alpha: 0.16),
          size: 34,
        ),
      ),
    );
  }
}
