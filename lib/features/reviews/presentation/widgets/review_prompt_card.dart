import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/reviews/domain/models/reviewable_reservation.dart';
import 'package:trim_flow/features/reviews/domain/repositories/reviews_repository.dart';
import 'package:trim_flow/features/reviews/presentation/widgets/rate_appointment_sheet.dart';

/// Tarjeta que invita al cliente a calificar su ultimo corte completado.
/// Se auto-oculta si no hay citas por reseñar.
class ReviewPromptCard extends StatefulWidget {
  const ReviewPromptCard({super.key});

  @override
  State<ReviewPromptCard> createState() => _ReviewPromptCardState();
}

class _ReviewPromptCardState extends State<ReviewPromptCard> {
  List<ReviewableReservation> _items = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await getIt<ReviewsRepository>().fetchReviewable();
      if (mounted) {
        setState(() {
          _items = items;
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  Future<void> _rate(ReviewableReservation r) async {
    HapticFeedback.lightImpact();
    final done = await RateAppointmentSheet.show(context, r);
    if (done == true && mounted) {
      setState(() => _items =
          _items.where((x) => x.reservationId != r.reservationId).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _items.isEmpty) return const SizedBox.shrink();
    final gold = context.primaryGold;
    final r = _items.first;
    final extra = _items.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: PremiumPressable(
        pressedScale: 0.985,
        onTap: () => _rate(r),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.solidStar, color: gold, size: 12),
                  const SizedBox(width: 7),
                  Text(
                    'CALIFICA TU CORTE',
                    style: GoogleFonts.inter(
                      color: gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const Spacer(),
                  if (extra > 0)
                    Text(
                      '+$extra por calificar',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${r.serviceName} · con ${r.barberName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var i = 0; i < 5; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FaIcon(FontAwesomeIcons.star,
                          color: gold.withValues(alpha: 0.55), size: 20),
                    ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border:
                          Border.all(color: gold.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Calificar',
                          style: GoogleFonts.inter(
                            color: gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: gold, size: 17),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: 0.06, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
    );
  }
}
