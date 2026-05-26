import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/reservations/domain/reservation_mock_data.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_bloc.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_event.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_state.dart';
import 'package:trim_flow/features/reservations/presentation/views/reservation_success_view.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/phase_1_center_selector.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/phase_2_service_selector.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/phase_3_professional_selector.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/phase_4_datetime_selector.dart';
import 'package:trim_flow/features/reservations/presentation/widgets/phase_5_confirmation_receipt.dart';
import 'package:trim_flow/features/home/view/home_page.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';

class ReservationView extends StatelessWidget {
  const ReservationView({super.key, required this.onGoHome});

  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return _ReservationContent(onGoHome: onGoHome);
  }
}

class _ReservationContent extends StatelessWidget {
  const _ReservationContent({required this.onGoHome});
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReservationBloc, ReservationState>(
      listener: (context, state) {
        if (state.status == ReservationStatus.success) {
          // Agregar a citas programadas del perfil
          context.read<ProfileBloc>().add(ProfileEvent.addScheduledReservation(state.reservation));
          
          // Resetear cartilla si tenía descuento especial activo
          if (state.isDiscountActive) {
            context.read<ProfileBloc>().add(const ProfileEvent.resetFidelityCount());
            context.read<ReservationBloc>().add(const ReservationEvent.deactivateDiscount());
          }

          // Navegación limpia al SuccessView
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => ReservationSuccessView(
                reservation: state.reservation,
                onGoHome: () {
                  // Como se usó pushAndRemoveUntil, la HomePage original se perdió.
                  // Navegamos a una nueva instancia de HomePage.
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
              ),
            ),
            (route) => false, // Elimina todas las rutas previas
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.backgroundBlack,
        body: BlocBuilder<ReservationBloc, ReservationState>(
          builder: (context, state) {
            final showStickyBar = state.currentPhase >= 1 && state.currentPhase <= 3;
            
            return Stack(
              children: [
                CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      backgroundColor: context.backgroundBlack,
                      expandedHeight: MediaQuery.of(context).size.height * 0.15,
                      pinned: true,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      flexibleSpace: FlexibleSpaceBar(
                        background: SafeArea(
                          child: Container(
                            color: context.backgroundBlack,
                            padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),
                                Icon(
                                  Icons.content_cut_rounded,
                                  color: context.primaryGold,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'RESERVAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: 40,
                                  height: 2,
                                  color: context.primaryGold,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
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
                            child: Phase4DateTimeSelector(
                              totalDurationInMinutes: state.reservation.totalDurationInMinutes,
                              selectedDate: state.reservation.date,
                              selectedTime: state.reservation.time,
                              occupiedTimes: ReservationMockData.occupiedTimes,
                              isCompleted: state.currentPhase > 4,
                              onSelectTime: (date, time) => context
                                  .read<ReservationBloc>()
                                  .add(ReservationEvent.selectDateTime(date, time)),
                              onConfirm: () => context
                                  .read<ReservationBloc>()
                                  .add(const ReservationEvent.goToPhase(5)),
                            ),
                          ),
                          _PhaseWrapper(
                            phase: 5,
                            currentPhase: state.currentPhase,
                            child: Phase5ConfirmationReceipt(
                              reservation: state.reservation,
                              isConfirming: state.status == ReservationStatus.loading,
                              isSuccess: state.status == ReservationStatus.success,
                              onConfirm: () => context
                                  .read<ReservationBloc>()
                                  .add(const ReservationEvent.confirmReservation()),
                              onGoHome: () {
                                context.read<ReservationBloc>().add(const ReservationEvent.reset());
                                onGoHome();
                              },
                            ),
                          ),
                          const SizedBox(height: 180),
                        ]),
                      ),
                    ),
                  ],
                ),
                if (showStickyBar)
                  Positioned(
                    bottom: 100,
                    left: 20,
                    right: 20,
                    child: _UniversalStickyBar(state: state),
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
  });

  final int phase;
  final int currentPhase;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isCompleted = currentPhase > phase;
    final isLocked = currentPhase < phase;

    if (isLocked) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_rounded, color: Colors.white.withValues(alpha: 0.2), size: 24),
            const SizedBox(height: 8),
            Text(
              'Fase $phase',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Completa el paso ${phase - 1} para continuar',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.15), fontSize: 11),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutQuart,
      margin: const EdgeInsets.only(bottom: 24),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: isCompleted ? 0.65 : 1.0,
        child: GestureDetector(
          onTap: isCompleted && currentPhase != 5
              ? () => context.read<ReservationBloc>().add(ReservationEvent.goToPhase(phase))
              : null,
          child: child,
        ),
      ),
    );
  }
}

class _UniversalStickyBar extends StatelessWidget {
  const _UniversalStickyBar({required this.state});
  final ReservationState state;

  @override
  Widget build(BuildContext context) {
    bool canContinue = false;
    String label = 'CONTINUAR';
    int nextPhase = state.currentPhase + 1;

    if (state.currentPhase == 1) {
      canContinue = state.reservation.center != null;
    } else if (state.currentPhase == 2) {
      canContinue = state.reservation.services.isNotEmpty;
    } else if (state.currentPhase == 3) {
      canContinue = state.professionalSelected; // Fix bloqueo
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.primaryGold.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getStepDescription(),
                  style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                Text(
                  _getSelectionSummary(),
                  style: TextStyle(color: context.primaryGold, fontSize: 16, fontWeight: FontWeight.w900),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canContinue
                ? () => context.read<ReservationBloc>().add(ReservationEvent.goToPhase(nextPhase))
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryGold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              disabledBackgroundColor: Colors.white10,
            ),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  String _getStepDescription() {
    switch (state.currentPhase) {
      case 1: return 'CENTRO SELECCIONADO';
      case 2: return '${state.reservation.services.length} SERVICIOS';
      case 3: return 'BARBERO ELEGIDO';
      default: return '';
    }
  }

  String _getSelectionSummary() {
    switch (state.currentPhase) {
      case 1: return state.reservation.center?.name ?? 'SIN SELECCIONAR';
      case 2: return 'S/ ${state.reservation.totalPrice.toStringAsFixed(2)}';
      case 3: return state.professionalSelected ? (state.reservation.professional?.name ?? 'MÁXIMA DISPONIBILIDAD') : 'SIN SELECCIONAR';
      default: return '';
    }
  }
}
