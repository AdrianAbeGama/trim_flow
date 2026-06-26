import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:core/core.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'profile_ticket_modal.dart';

class ProfileActiveAppointmentsCard extends StatelessWidget {
  final List<Reservation> appointments;
  final bool isExpanded;
  final VoidCallback onTap;

  const ProfileActiveAppointmentsCard({
    super.key,
    required this.appointments,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Elegant Category Header (Always visible now)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 3.0,
                height: 13,
                decoration: BoxDecoration(
                  color: context.primaryGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'CITAS PROGRAMADAS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        // List of glassmorphic cards directly rendered
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: appointments.isEmpty
              ? _buildEmptyState(context)
              : Column(
                  children: appointments.map((record) => _GlassmorphicAppointmentCard(record: record)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.03),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: context.primaryGold.withValues(alpha: 0.4),
                size: 28,
              ),
              const SizedBox(height: 12),
              const Text(
                'Sin citas activas',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'No tienes citas programadas para hoy o mañana.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassmorphicAppointmentCard extends StatefulWidget {
  final Reservation record;
  const _GlassmorphicAppointmentCard({required this.record});

  @override
  State<_GlassmorphicAppointmentCard> createState() => _GlassmorphicAppointmentCardState();
}

class _GlassmorphicAppointmentCardState extends State<_GlassmorphicAppointmentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  static const List<String> _cancelReasons = [
    'Tuve un accidente',
    'Tuve un problema personal',
    'Ya no puedo asistir ese día',
    'Cambié de opinión',
    'Emergencia familiar',
    'Otro motivo',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showCancelDialog(BuildContext ctx) {
    final accent = ctx.primaryGold;
    showDialog(
      context: ctx,
      builder: (dialogCtx) => Dialog(
        backgroundColor: const Color(0xFF0F0F0F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: accent.withValues(alpha: 0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'CANCELAR CITA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona el motivo de tu cancelación:',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              ..._cancelReasons.map((reason) => _ReasonTile(
                    reason: reason,
                    onTap: () {
                      Navigator.pop(dialogCtx);
                      ctx.read<ProfileBloc>().add(
                            ProfileEvent.cancelAppointment(
                              reservationId: widget.record.id ?? '',
                              reason: reason,
                            ),
                          );
                    },
                  )),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Volver', style: TextStyle(color: Colors.white54)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Calcula el countdown human-friendly para la cita.
  /// "HOY 09:30", "MAÑANA 14:00", "EN 3 DÍAS", "EL 15 DE JUN"
  ({String label, bool isImminent}) _countdownLabel(DateTime? date, String? time) {
    if (date == null) return (label: '', isImminent: false);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diffDays = target.difference(today).inDays;
    final hhmm = (time ?? '').isEmpty ? '' : ' · $time';

    if (diffDays == 0) return (label: 'HOY$hhmm', isImminent: true);
    if (diffDays == 1) return (label: 'MAÑANA$hhmm', isImminent: true);
    if (diffDays > 1 && diffDays <= 7) return (label: 'EN $diffDays DÍAS', isImminent: false);
    if (diffDays < 0) return (label: 'YA PASÓ', isImminent: false);
    final monthShort = DateFormat('MMM', 'es').format(target).toUpperCase();
    return (label: 'EL ${target.day} DE $monthShort', isImminent: false);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = widget.record.date != null
        ? DateFormat("EEE d 'de' MMM", 'es').format(widget.record.date!)
        : '—';
    final timeStr = widget.record.time ?? '—';
    final rawCenterName = widget.record.center?.name.trim() ?? '';
    final hasSede = rawCenterName.isNotEmpty &&
        rawCenterName != 'Sede por confirmar';
    final centerName =
        hasSede ? rawCenterName : 'Sede no disponible';
    final professionalName = widget.record.professional?.name ?? 'Disponible';
    final serviceNames = widget.record.services.map((s) => s.name).join(', ');
    final priceStr = 'S/ ${widget.record.totalPrice.toStringAsFixed(2)}';
    final countdown = _countdownLabel(widget.record.date, widget.record.time);
    final accent = context.primaryGold;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.03),
                width: 1,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Header: Countdown badge + CONFIRMADA pill
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (countdown.label.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: countdown.isImminent
                                        ? accent.withValues(alpha: 0.18)
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: countdown.isImminent
                                          ? accent.withValues(alpha: 0.45)
                                          : Colors.white.withValues(alpha: 0.08),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    countdown.label,
                                    style: TextStyle(
                                      color: countdown.isImminent ? accent : Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              // Pulsing Green dot + CONFIRMADA text
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) {
                                      return Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.greenAccent.withValues(
                                            alpha: 0.5 + (_pulseController.value * 0.5),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.greenAccent.withValues(
                                                alpha: 0.3 * _pulseController.value,
                                              ),
                                              blurRadius: 4 * _pulseController.value,
                                              spreadRadius: 2 * _pulseController.value,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'CONFIRMADA',
                                    style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Servicio (línea principal)
                          Text(
                            serviceNames,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Barbero · Fecha
                          Row(
                            children: [
                              Icon(Icons.content_cut_rounded, color: Colors.white54, size: 13),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '$professionalName  ·  $dateStr · $timeStr',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Sede + Precio
                          Row(
                            children: [
                              Icon(Icons.place_outlined, color: Colors.white.withValues(alpha: hasSede ? 0.5 : 0.25), size: 13),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  centerName,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: hasSede ? 0.55 : 0.3),
                                    fontSize: 11,
                                    fontStyle: hasSede ? FontStyle.normal : FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                priceStr,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          const Divider(color: Colors.white10, height: 1),
                          const SizedBox(height: 8),

                          // Highly styled premium buttons: [Ver Ticket] and [Cancelar] (Compact & Minimal)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Ver Ticket - Sleek low-profile gold outline
                              OutlinedButton.icon(
                                onPressed: () => ProfileTicketModal.show(context, widget.record),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: context.primaryGold,
                                  side: BorderSide(
                                    color: context.primaryGold.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: Colors.transparent,
                                ),
                                icon: Icon(Icons.qr_code_2_rounded, size: 14, color: context.primaryGold),
                                label: const Text(
                                  'Ver Ticket',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Cancelar Cita - Sleek low-profile red outline
                              OutlinedButton.icon(
                                onPressed: () => _showCancelDialog(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent.withValues(alpha: 0.7),
                                  side: BorderSide(
                                    color: Colors.redAccent.withValues(alpha: 0.15),
                                    width: 1,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: Colors.transparent,
                                ),
                                icon: Icon(Icons.close_rounded, size: 14, color: Colors.redAccent.withValues(alpha: 0.7)),
                                label: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final String reason;
  final VoidCallback onTap;

  const _ReasonTile({required this.reason, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            const Icon(Icons.radio_button_unchecked_rounded, color: Colors.redAccent, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reason,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
