import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/avatar_premium.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/presentation/widgets/status_badge.dart';

Color _statusColor(BuildContext context, AgendaStatus s) {
  switch (s) {
    case AgendaStatus.pending:
      return context.primaryGold;
    case AgendaStatus.confirmed:
      return Colors.white;
    case AgendaStatus.completed:
      return const Color(0xFF6FAE8A);
    case AgendaStatus.cancelled:
    case AgendaStatus.noShow:
      return const Color(0xFFCF6679);
    case AgendaStatus.unknown:
      return Colors.white24;
  }
}

String _hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Seccion (solo lectura) del perfil del barbero: proximo cliente destacado +
/// linea de tiempo vertical de las citas de hoy. Tocar abre la ficha.
class BarberProfileTodayAgenda extends StatelessWidget {
  const BarberProfileTodayAgenda({
    super.key,
    required this.appointments,
    required this.loading,
  });

  final List<AgendaAppointment> appointments;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    AgendaAppointment? next;
    for (final a in appointments) {
      if (a.startTime.isAfter(now) &&
          (a.status == AgendaStatus.confirmed ||
              a.status == AgendaStatus.pending)) {
        next = a;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (next != null) _NextClientCard(appointment: next, onTap: () => _peek(context, next!)),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.timeline_rounded, size: 16, color: context.primaryGold),
                  const SizedBox(width: 8),
                  Text('Tu agenda de hoy', style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  const Spacer(),
                  if (appointments.isNotEmpty)
                    Text('${appointments.length} citas', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.35), fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 14),
              if (loading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 26),
                  child: Center(
                    child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: context.primaryGold)),
                  ),
                )
              else if (appointments.isEmpty)
                _EmptyToday()
              else
                Column(
                  children: [
                    for (var i = 0; i < appointments.length; i++)
                      _TimelineTile(
                        appointment: appointments[i],
                        isFirst: i == 0,
                        isLast: i == appointments.length - 1,
                        onTap: () => _peek(context, appointments[i]),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _peek(BuildContext context, AgendaAppointment appointment) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ClientPeekSheet(appointment: appointment),
    );
  }
}

class _NextClientCard extends StatelessWidget {
  const _NextClientCard({required this.appointment, required this.onTap});

  final AgendaAppointment appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final name = appointment.customerName ?? 'Cliente sin registrar';
    final service = appointment.serviceName ?? 'Servicio';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: PremiumPressable(
        pressedScale: 0.98,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gold.withValues(alpha: 0.14), const Color(0xFF111111)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: gold.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              AvatarPremium(displayName: name, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRÓXIMO CLIENTE', style: GoogleFonts.inter(color: gold, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.6)),
                    const SizedBox(height: 4),
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
                    const SizedBox(height: 2),
                    Text('${_hhmm(appointment.startTime)} · $service', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.55), fontSize: 12.5, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              if (appointment.priceAtBooking != null)
                Text('S/ ${appointment.priceAtBooking!.toStringAsFixed(0)}', style: GoogleFonts.inter(color: gold, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.appointment,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final AgendaAppointment appointment;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dot = _statusColor(context, appointment.status);
    final line = Colors.white.withValues(alpha: 0.1);
    final name = appointment.customerName ?? 'Cliente sin registrar';
    final service = appointment.serviceName ?? 'Servicio';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 46,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_hhmm(appointment.startTime), style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.55), fontSize: 12.5, fontWeight: FontWeight.w800)),
            ),
          ),
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(width: 2, height: 14, color: isFirst ? Colors.transparent : line),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dot,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: dot.withValues(alpha: 0.4), blurRadius: 5)],
                  ),
                ),
                Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : line)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PremiumPressable(
                pressedScale: 0.98,
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                            const SizedBox(height: 2),
                            Text(service, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AgendaStatusBadge(status: appointment.status, compact: true),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyToday extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(Icons.event_available_rounded, size: 26, color: Colors.white.withValues(alpha: 0.25)),
          const SizedBox(height: 10),
          Text('Sin citas para hoy', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text('Cuando tengas citas, aparecerán aquí.', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.3), fontSize: 11.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ClientPeekSheet extends StatelessWidget {
  const _ClientPeekSheet({required this.appointment});

  final AgendaAppointment appointment;

  Future<void> _contact(BuildContext context, String raw) async {
    final messenger = ScaffoldMessenger.of(context);
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    try {
      final ok = await launchUrl(Uri.parse('https://wa.me/$digits'), mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {}
    await Clipboard.setData(ClipboardData(text: raw));
    messenger.showSnackBar(const SnackBar(backgroundColor: Color(0xFF1A1A1A), content: Text('Número copiado.')));
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final name = appointment.customerName ?? 'Cliente sin registrar';
    final service = appointment.serviceName ?? 'Servicio no especificado';
    final whatsapp = appointment.customerWhatsapp;

    return Container(
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
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarPremium(displayName: name, size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AgendaStatusBadge(status: appointment.status, compact: true),
                      const SizedBox(height: 8),
                      Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.1)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_hhmm(appointment.startTime)} - ${_hhmm(appointment.endTime)}', style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(service, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                if (appointment.priceAtBooking != null)
                  Text('S/ ${appointment.priceAtBooking!.toStringAsFixed(0)}', style: GoogleFonts.inter(color: gold, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.6)),
              ],
            ),
            if (whatsapp != null && whatsapp.trim().isNotEmpty) ...[
              const SizedBox(height: 18),
              PremiumPressable(
                pressedScale: 0.97,
                onTap: () => _contact(context, whatsapp),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.whatsapp, size: 15, color: Color(0xFF25D366)),
                      const SizedBox(width: 8),
                      Text('Escribir por WhatsApp', style: GoogleFonts.inter(color: const Color(0xFF25D366), fontSize: 13, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              'Completar o marcar "no asistió" desde la pestaña Agenda.',
              style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.35), fontSize: 11.5, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
