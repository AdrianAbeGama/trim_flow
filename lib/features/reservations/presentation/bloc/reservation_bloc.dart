import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/features/reservations/domain/reservation_mock_data.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_event.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_state.dart';
import 'package:core/core.dart';

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  ReservationBloc() : super(const ReservationState(
    reservation: Reservation(tenantId: ReservationMockData.tenantId)
  )) {
    on<ReservationEvent>((event, emit) async {
      await event.map(
        selectCenter: (e) async {
          final updatedReservation = state.reservation.copyWith(center: e.center);
          emit(state.copyWith(
            reservation: updatedReservation,
          ));
        },
        toggleService: (e) async {
          final isSelected = state.reservation.services.any((s) => s.id == e.service.id);
          final services = isSelected ? <Service>[] : <Service>[e.service];

          final basePrice = services.fold(0.0, (sum, item) => sum + item.price);
          final totalPrice = state.isDiscountActive ? basePrice * 0.5 : basePrice;
          final totalDuration = services.fold(0, (sum, item) => sum + item.durationInMinutes);

          emit(state.copyWith(
            reservation: state.reservation.copyWith(
              services: services,
              totalPrice: totalPrice,
              totalDurationInMinutes: totalDuration,
            ),
          ));
        },
        selectProfessional: (e) async {
          emit(state.copyWith(
            reservation: state.reservation.copyWith(professional: e.professional),
            professionalSelected: true, // Mark as selected
          ));
        },
        selectDateTime: (e) async {
          emit(state.copyWith(
            reservation: state.reservation.copyWith(
              date: e.date,
              time: e.time,
            ),
          ));
        },
        goToPhase: (e) async {
          emit(state.copyWith(currentPhase: e.phase));
        },
        confirmReservation: (e) async {
          emit(state.copyWith(status: ReservationStatus.loading));
          await Future.delayed(const Duration(seconds: 2)); // Simulate network request
          final current = state.reservation;
          final withId = (current.id == null || current.id!.isEmpty)
              ? current.copyWith(id: 'tf_${DateTime.now().millisecondsSinceEpoch}')
              : current;
          emit(state.copyWith(status: ReservationStatus.success, reservation: withId));
        },
        activateDiscount: (e) async {
          final basePrice = state.reservation.services.fold(0.0, (sum, item) => sum + item.price);
          emit(state.copyWith(
            isDiscountActive: true,
            reservation: state.reservation.copyWith(
              totalPrice: basePrice * 0.5,
            ),
          ));
        },
        deactivateDiscount: (e) async {
          final basePrice = state.reservation.services.fold(0.0, (sum, item) => sum + item.price);
          emit(state.copyWith(
            isDiscountActive: false,
            reservation: state.reservation.copyWith(
              totalPrice: basePrice,
            ),
          ));
        },
        reset: (e) async {
          emit(const ReservationState(
            reservation: Reservation(tenantId: ReservationMockData.tenantId),
            isDiscountActive: false,
          ));
        },
      );
    });
  }
}
