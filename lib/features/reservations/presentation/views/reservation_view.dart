import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/notifications/appointment_reminders.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/reservation_progress.dart';
import 'package:trim_flow/features/reservations/domain/reservation_mock_data.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_bloc.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_event.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_state.dart';
import 'package:trim_flow/features/reservations/presentation/views/reservation_landing.dart';
import 'package:trim_flow/features/reservations/presentation/views/reservation_success_view.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/phase_1_center_selector.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/phase_2_service_selector.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/phase_3_professional_selector.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/phase_4_datetime_selector.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/phase_5_confirmation_receipt.dart';
import 'package:trim_flow/features/home/view/home_page.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

class ReservationView extends StatefulWidget {
  const ReservationView({super.key, required this.onGoHome});

  final VoidCallback onGoHome;

  @override
  State<ReservationView> createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView> {
  bool _makingNew = false;

  @override
  void initState() {
    super.initState();
    HomePage.requestedService.addListener(_handleRequestedService);
    // Procesa request pendiente si llegó antes de que esta vista existiera
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleRequestedService());
  }

  @override
  void dispose() {
    HomePage.requestedService.removeListener(_handleRequestedService);
    super.dispose();
  }

  void _handleRequestedService() {
    final requested = HomePage.requestedService.value;
    if (requested == null || !mounted) return;
    final name = requested['title'] ?? '';
    if (name.isEmpty) {
      HomePage.requestedService.value = null;
      return;
    }
    // Viene un servicio preseleccionado desde Home → abrir el wizard.
    setState(() => _makingNew = true);
    // Busca el servicio matching en el mock (case-insensitive)
    final match = ReservationMockData.services.where(
      (s) => s.name.toLowerCase() == name.toLowerCase(),
    ).firstOrNull;
    if (match != null) {
      context.read<ReservationBloc>()
        ..add(ReservationEvent.toggleService(match))
        ..add(const ReservationEvent.goToPhase(2));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Servicio preseleccionado: $name'),
        duration: const Duration(seconds: 2),
        backgroundColor: context.primaryGold,
      ),
    );
    HomePage.requestedService.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (a, b) => a.scheduledAppointments != b.scheduledAppointments,
      builder: (context, profileState) {
        final appts = profileState.scheduledAppointments;
        if (appts.isNotEmpty && !_makingNew) {
          return ReservationLanding(
            appointments: appts,
            onNew: () {
              context.read<ReservationBloc>().add(const ReservationEvent.reset());
              setState(() => _makingNew = true);
            },
          );
        }
        return _ReservationContent(
          onExitToLanding: appts.isNotEmpty ? () => setState(() => _makingNew = false) : null,
        );
      },
    );
  }
}

class _ReservationContent extends StatelessWidget {
  const _ReservationContent({this.onExitToLanding});
  final VoidCallback? onExitToLanding;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReservationBloc, ReservationState>(
      listenWhen: (previous, current) =>
          previous.status != ReservationStatus.success && current.status == ReservationStatus.success,
      listener: (context, state) {
        if (state.status == ReservationStatus.success) {
          final reservationBloc = context.read<ReservationBloc>();

          // Agregar a citas programadas del perfil
          context.read<ProfileBloc>().add(ProfileEvent.addScheduledReservation(state.reservation));

          // Programar recordatorios locales (24h + 1h antes)
          final reservation = state.reservation;
          if (reservation.id != null && reservation.date != null && (reservation.time ?? '').isNotEmpty) {
            final parts = reservation.time!.split(':');
            if (parts.length == 2) {
              final hour = int.tryParse(parts[0]);
              final minute = int.tryParse(parts[1]);
              if (hour != null && minute != null) {
                final fullDate = DateTime(
                  reservation.date!.year,
                  reservation.date!.month,
                  reservation.date!.day,
                  hour,
                  minute,
                );
                AppointmentReminders.schedule(
                  reservationId: reservation.id!,
                  appointmentDateTime: fullDate,
                  serviceName: reservation.services.map((s) => s.name).join(', '),
                  barberName: reservation.professional?.name ?? 'Tu barbero',
                );
              }
            }
          }

          // Resetear cartilla si tenía descuento especial activo
          if (state.isDiscountActive) {
            context.read<ProfileBloc>().add(const ProfileEvent.resetFidelityCount());
          }

          // Navegación limpia al SuccessView
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => ReservationSuccessView(
                reservation: state.reservation,
                onGoToProfile: () {
                  HomePage.requestedTab.value = 4; // tab perfil
                  HomePage.justBooked.value = true;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
              ),
            ),
            (route) => false, // Elimina todas las rutas previas
          );

          // Limpia el wizard para que al volver al tab Reservar arranque fresco
          // en paso 1 (evita ver "5 de 5" con botones EDITAR tras reservar).
          reservationBloc.add(const ReservationEvent.reset());
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: BlocBuilder<ReservationBloc, ReservationState>(
          builder: (context, state) {
            return Stack(
              children: [
                CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const PremiumPill(icon: Icons.content_cut_rounded, label: 'AGENDA TU CITA'),
                                  const Spacer(),
                                  if (onExitToLanding != null)
                                    _HeaderIconButton(icon: Icons.event_note_rounded, onTap: onExitToLanding!),
                                ],
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms)
                                  .slideY(begin: -0.3, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
                              const SizedBox(height: 22),
                              Text(
                                'Agenda tu',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.55), letterSpacing: -0.2),
                              )
                                  .animate()
                                  .fadeIn(delay: 120.ms, duration: 500.ms)
                                  .slideY(begin: 0.3, end: 0, delay: 120.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                              const SizedBox(height: 4),
                              Text(
                                'Reservar',
                                style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.6, height: 1.05),
                              )
                                  .animate()
                                  .fadeIn(delay: 200.ms, duration: 600.ms)
                                  .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(width: 16, height: 1.5, color: context.primaryGold),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Reserva en pocos pasos',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.45), letterSpacing: -0.1),
                                  ),
                                ],
                              )
                                  .animate()
                                  .fadeIn(delay: 320.ms, duration: 500.ms),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          ReservationProgress(currentPhase: state.currentPhase),
                          const SizedBox(height: 22),
                          if (state.isDiscountActive) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161208), // Luxury dark gold tint
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: context.primaryGold,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.primaryGold.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.stars_rounded,
                                    color: context.primaryGold,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'BENEFICIO DE FIDELIZACIÓN',
                                          style: TextStyle(
                                            color: context.primaryGold,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          '¡50% de descuento automático en tu corte!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          _PhaseWrapper(
                            phase: 1,
                            currentPhase: state.currentPhase,
                            summaryLabel: 'Centro',
                            summaryValue: state.reservation.center?.name ?? '—',
                            child: Phase1CenterSelector(
                              centers: ReservationMockData.centers,
                              selectedCenter: state.reservation.center,
                              isCompleted: state.currentPhase > 1,
                              onSelect: (center) => context
                                  .read<ReservationBloc>()
                                  .add(ReservationEvent.selectCenter(center)),
                            ),
                          ),
                          _PhaseWrapper(
                            phase: 2,
                            currentPhase: state.currentPhase,
                            summaryLabel: 'Servicio',
                            summaryValue: state.reservation.services.isNotEmpty
                                ? '${state.reservation.services.first.name} · S/ ${state.reservation.totalPrice.toStringAsFixed(2)}'
                                : '—',
                            child: Phase2ServiceSelector(
                              services: ReservationMockData.services,
                              selectedServices: state.reservation.services,
                              isCompleted: state.currentPhase > 2,
                              onToggle: (service) => context
                                  .read<ReservationBloc>()
                                  .add(ReservationEvent.toggleService(service)),
                            ),
                          ),
                          _PhaseWrapper(
                            phase: 3,
                            currentPhase: state.currentPhase,
                            summaryLabel: 'Barbero',
                            summaryValue: state.professionalSelected
                                ? (state.reservation.professional?.name ?? 'Máxima disponibilidad')
                                : '—',
                            child: Phase3ProfessionalSelector(
                              professionals: ReservationMockData.professionals,
                              selectedProfessional: state.reservation.professional,
                              hasSelectedAny: state.professionalSelected, // Corregido el bug de bloqueo
                              isCompleted: state.currentPhase > 3,
                              onSelect: (prof) => context
                                  .read<ReservationBloc>()
                                  .add(ReservationEvent.selectProfessional(prof)),
                            ),
                          ),
                          _PhaseWrapper(
                            phase: 4,
                            currentPhase: state.currentPhase,
                            summaryLabel: 'Fecha y hora',
                            summaryValue: (state.reservation.date != null && state.reservation.time != null)
                                ? '${DateFormat("d MMM", 'es').format(state.reservation.date!)} · ${state.reservation.time}'
                                : '—',
                            child: Phase4DateTimeSelector(
                              totalDurationInMinutes: state.reservation.totalDurationInMinutes,
                              selectedDate: state.reservation.date,
                              selectedTime: state.reservation.time,
                              occupiedTimes: ReservationMockData.occupiedTimes,
                              isCompleted: state.currentPhase > 4,
                              onSelectTime: (date, time) => context
                                  .read<ReservationBloc>()
                                  .add(ReservationEvent.selectDateTime(date, time)),
                            ),
                          ),
                          _PhaseWrapper(
                            phase: 5,
                            currentPhase: state.currentPhase,
                            child: Phase5ConfirmationReceipt(
                              reservation: state.reservation,
                              isSuccess: state.status == ReservationStatus.success,
                            ),
                          ),
                          const SizedBox(height: 180),
                        ]),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 100,
                  left: 20,
                  right: 20,
                  child: _BottomNavBar(state: state, onExitToLanding: onExitToLanding),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PhaseWrapper extends StatelessWidget {
  const _PhaseWrapper({
    required this.phase,
    required this.currentPhase,
    required this.child,
    this.summaryLabel,
    this.summaryValue,
  });

  final int phase;
  final int currentPhase;
  final Widget child;
  final String? summaryLabel;
  final String? summaryValue;

  @override
  Widget build(BuildContext context) {
    final isCompleted = currentPhase > phase;
    final isLocked = currentPhase < phase;

    if (isLocked) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.015),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
                child: Text('$phase',
                    style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.25), fontSize: 12, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  summaryLabel ?? 'Paso $phase',
                  style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.3), fontSize: 13.5, fontWeight: FontWeight.w700, letterSpacing: -0.2),
                ),
              ),
              Icon(Icons.lock_rounded, color: Colors.white.withValues(alpha: 0.18), size: 16),
            ],
          ),
        ),
      );
    }

    if (isCompleted) {
      // En el paso 5 se ocultan: el resumen unificado los reemplaza.
      if (currentPhase >= 5 || summaryValue == null) return const SizedBox.shrink();
      return _CompletedStepRow(label: summaryLabel ?? 'Paso $phase', value: summaryValue!);
    }

    // Activo
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: child,
    )
        .animate()
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.9,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, color: context.primaryGold, size: 19),
      ),
    );
  }
}

class _CompletedStepRow extends StatelessWidget {
  const _CompletedStepRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: gold, size: 20),
          const SizedBox(width: 12),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700, letterSpacing: -0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.state, this.onExitToLanding});
  final ReservationState state;
  final VoidCallback? onExitToLanding;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final phase = state.currentPhase;
    final isLoading = state.status == ReservationStatus.loading;
    // "Atrás" disponible desde el paso 2; en el paso 1 solo si se puede volver
    // al landing de "tus citas".
    final showBack = phase > 1 || onExitToLanding != null;

    bool canForward;
    String label;
    switch (phase) {
      case 1:
        canForward = state.reservation.center != null;
        label = 'CONTINUAR';
        break;
      case 2:
        canForward = state.reservation.services.isNotEmpty;
        label = 'CONTINUAR';
        break;
      case 3:
        canForward = state.professionalSelected;
        label = 'CONTINUAR';
        break;
      case 4:
        canForward = state.reservation.date != null && state.reservation.time != null;
        label = 'ACEPTAR';
        break;
      default:
        canForward = !isLoading;
        label = 'CONFIRMAR RESERVA';
        break;
    }

    void onForward() {
      if (phase >= 5) {
        context.read<ReservationBloc>().add(const ReservationEvent.confirmReservation());
      } else {
        context.read<ReservationBloc>().add(ReservationEvent.goToPhase(phase + 1));
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(0, 4)),
        ],
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          if (showBack) ...[
            PremiumPressable(
              pressedScale: 0.95,
              onTap: () {
                if (phase > 1) {
                  context.read<ReservationBloc>().add(ReservationEvent.goToPhase(phase - 1));
                } else {
                  onExitToLanding?.call();
                }
              },
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 26),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(
                  'ATRÁS',
                  style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.75), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: PremiumPressable(
              pressedScale: 0.98,
              onTap: canForward ? onForward : null,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: canForward ? gold : Colors.white10,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: (isLoading && phase >= 5)
                    ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 3, color: premiumOnAccent(gold)))
                    : Text(
                        label,
                        style: GoogleFonts.inter(
                          color: canForward ? premiumOnAccent(gold) : Colors.white24,
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
    );
  }
}
