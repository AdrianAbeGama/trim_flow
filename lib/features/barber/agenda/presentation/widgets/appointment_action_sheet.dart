import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trim_flow/core/notifications/appointment_reminders.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/avatar_premium.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_event.dart';
import 'package:trim_flow/features/barber/agenda/presentation/widgets/status_badge.dart';

const List<String> _kCancelReasons = [
  'Barbero no disponible',
  'El cliente lo solicitó',
  'Local cerrado / imprevisto',
  'Horario duplicado',
  'Otro motivo',
];

class AppointmentActionSheet extends StatelessWidget {
  const AppointmentActionSheet({super.key, required this.appointment});

  final AgendaAppointment appointment;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final name = appointment.customerName ?? 'Cliente sin registrar';
    final service = appointment.serviceName ?? 'Servicio no especificado';

    final hh = appointment.startTime.hour.toString().padLeft(2, '0');
    final mm = appointment.startTime.minute.toString().padLeft(2, '0');
    final eh = appointment.endTime.hour.toString().padLeft(2, '0');
    final em = appointment.endTime.minute.toString().padLeft(2, '0');
    final timeStr = '$hh:$mm - $eh:$em';

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
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarPremium(displayName: name, size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AgendaStatusBadge(status: appointment.status, compact: true),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                _CloseButton(onTap: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),
            // Resumen limpio: hora · servicio + precio destacado
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(timeStr, style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                      const SizedBox(height: 3),
                      Text(service, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                if (appointment.priceAtBooking != null)
                  Text(
                    'S/ ${appointment.priceAtBooking!.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(color: gold, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.8),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 14),
            _ClientStrip(appointment: appointment),
            const SizedBox(height: 22),
            if (appointment.status == AgendaStatus.pending) ...[
              // Cita por confirmar: aceptar el pedido o cancelarlo.
              _PrimaryAction(
                label: 'CONFIRMAR CITA',
                icon: Icons.check_circle_rounded,
                onTap: () => _handleConfirm(context),
              ),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: _DangerAction(label: 'CANCELAR', onTap: () => _handleCancel(context))),
            ] else if (appointment.status == AgendaStatus.confirmed) ...[
              // Cita confirmada: completar el corte, marcar no-show o cancelar.
              _PrimaryAction(
                label: 'COMPLETAR CORTE',
                icon: Icons.content_cut_rounded,
                onTap: () => _handleComplete(context),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _GhostAction(label: 'NO ASISTIÓ', onTap: () => _handleNoShow(context))),
                  const SizedBox(width: 10),
                  Expanded(child: _DangerAction(label: 'CANCELAR', onTap: () => _handleCancel(context))),
                ],
              ),
            ] else
              Center(
                child: Text(
                  'Cita ${appointment.status.label.toLowerCase()}',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleConfirm(BuildContext context) {
    HapticFeedback.mediumImpact();
    context.read<AgendaBloc>().add(AgendaEvent.statusChanged(appointment.id, AgendaStatus.confirmed));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(backgroundColor: Color(0xFF1A1A1A), content: Text('Cita confirmada.')),
    );
  }

  void _handleComplete(BuildContext context) {
    HapticFeedback.mediumImpact();
    context.read<AgendaBloc>().add(AgendaEvent.statusChanged(appointment.id, AgendaStatus.completed));
    Navigator.pop(context);
  }

  void _handleNoShow(BuildContext context) {
    HapticFeedback.mediumImpact();
    context.read<AgendaBloc>().add(AgendaEvent.statusChanged(appointment.id, AgendaStatus.noShow));
    AppointmentReminders.cancel(appointment.id);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF1A1A1A),
        content: Text('Marcada como no asistió.'),
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context) async {
    final bloc = context.read<AgendaBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final reason = await _showCancelReasons(context);
    if (reason == null) return;

    bloc.add(AgendaEvent.statusChanged(appointment.id, AgendaStatus.cancelled, reason: reason));
    AppointmentReminders.cancel(appointment.id);
    navigator.pop();

    final paid = appointment.priceAtBooking != null && appointment.priceAtBooking! > 0;
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A1A),
        duration: const Duration(seconds: 4),
        content: Text(
          paid
              ? 'Cita cancelada · Cliente notificado · Se gestionará la devolución de S/ ${appointment.priceAtBooking!.toStringAsFixed(2)}'
              : 'Cita cancelada · Cliente notificado',
        ),
      ),
    );
  }

  Future<String?> _showCancelReasons(BuildContext context) {
    final gold = context.primaryGold;
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF141414),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(Icons.report_problem_rounded, size: 18, color: gold),
                  const SizedBox(width: 10),
                  Text(
                    'Motivo de cancelación',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.4),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Se le informará al cliente con este motivo.',
                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ..._kCancelReasons.map((r) => _ReasonTile(label: r, onTap: () => Navigator.pop(ctx, r))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientStrip extends StatelessWidget {
  const _ClientStrip({required this.appointment});

  final AgendaAppointment appointment;

  Future<void> _contactClient(BuildContext context, String raw) async {
    final messenger = ScaffoldMessenger.of(context);
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$digits');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {}
    await Clipboard.setData(ClipboardData(text: raw));
    messenger.showSnackBar(
      const SnackBar(backgroundColor: Color(0xFF1A1A1A), content: Text('Número copiado al portapapeles.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = context.read<AgendaBloc>().state.appointments;
    final key = appointment.customerWhatsapp ?? appointment.customerName;
    final visits = all.where((a) => (a.customerWhatsapp ?? a.customerName) == key).length;
    final whatsapp = appointment.customerWhatsapp;

    return Row(
      children: [
        Icon(Icons.person_rounded, size: 15, color: Colors.white.withValues(alpha: 0.4)),
        const SizedBox(width: 8),
        Text(
          '$visits ${visits == 1 ? "cita" : "citas"} en agenda',
          style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (whatsapp != null && whatsapp.trim().isNotEmpty)
          PremiumPressable(
            pressedScale: 0.9,
            onTap: () => _contactClient(context, whatsapp),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(FontAwesomeIcons.whatsapp, size: 13, color: Color(0xFF25D366)),
                  const SizedBox(width: 6),
                  Text('WhatsApp', style: GoogleFonts.inter(color: const Color(0xFF25D366), fontSize: 11, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85), letterSpacing: -0.2),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 16, color: Colors.white.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return PremiumPressable(
      pressedScale: 0.97,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gold,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: premiumOnAccent(gold), size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(color: premiumOnAccent(gold), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostAction extends StatelessWidget {
  const _GhostAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.96,
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8),
        ),
      ),
    );
  }
}

class _DangerAction extends StatelessWidget {
  const _DangerAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const danger = Color(0xFFCF6679);
    return PremiumPressable(
      pressedScale: 0.96,
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: danger.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(color: danger, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.88,
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
      ),
    );
  }
}
