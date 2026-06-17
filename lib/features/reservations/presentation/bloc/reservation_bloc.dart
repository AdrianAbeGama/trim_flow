import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trim_flow/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_event.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_state.dart';

@injectable
class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final ReservationRepository _repository;

  ReservationBloc(this._repository)
      : super(const ReservationState(reservation: Reservation(tenantId: ''))) {
    on<ReservationEvent>((event, emit) async {
      await event.map(
        selectCenter: (e) async {
          emit(state.copyWith(
            reservation: state.reservation.copyWith(center: e.center),
          ));
        },
        toggleService: (e) async {
          final isSelected =
              state.reservation.services.any((s) => s.id == e.service.id);
          final services = isSelected ? <Service>[] : <Service>[e.service];
          final basePrice = services.fold(0.0, (sum, item) => sum + item.price);
          final totalPrice = state.isDiscountActive ? basePrice * 0.5 : basePrice;
          final totalDuration =
              services.fold(0, (sum, item) => sum + item.durationInMinutes);
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
            reservation:
                state.reservation.copyWith(professional: e.professional),
            professionalSelected: true,
          ));
        },
        loadSlots: (e) async {
          final center = state.reservation.center;
          final service = state.reservation.services.isNotEmpty
              ? state.reservation.services.first
              : null;
          if (center == null || service == null) return;
          emit(state.copyWith(
            slotsStatus: SlotsStatus.loading,
            availableSlots: const <DateTime>[],
            effectiveBarberId: e.barberId,
            selectedSlotUtc: null,
            idempotencyKey: null,
            reservation: state.reservation.copyWith(date: e.date, time: null),
          ));
          try {
            final slots = await _repository.fetchAvailableSlots(
              tenantId: center.tenantId,
              branchId: center.id,
              barberId: e.barberId,
              serviceId: service.id,
              date: e.date,
            );
            emit(state.copyWith(
              slotsStatus: SlotsStatus.loaded,
              availableSlots: slots,
            ));
          } catch (_) {
            emit(state.copyWith(
              slotsStatus: SlotsStatus.error,
              availableSlots: const <DateTime>[],
            ));
          }
        },
        selectSlot: (e) async {
          final local = e.startUtc.toLocal();
          emit(state.copyWith(
            selectedSlotUtc: e.startUtc,
            idempotencyKey: null,
            reservation: state.reservation.copyWith(
              date: local,
              time: _fmtTime(local),
            ),
          ));
        },
        goToPhase: (e) async {
          emit(state.copyWith(currentPhase: e.phase));
          if (e.phase >= 5 && state.availableCoupons.isEmpty) {
            final center = state.reservation.center;
            if (center != null) {
              try {
                final coupons = await _repository.fetchUsableCoupons(
                    tenantId: center.tenantId);
                if (coupons.isNotEmpty) {
                  emit(state.copyWith(availableCoupons: coupons));
                }
              } catch (_) {}
            }
          }
        },
        loadCoupons: (e) async {
          final center = state.reservation.center;
          if (center == null) return;
          try {
            final coupons =
                await _repository.fetchUsableCoupons(tenantId: center.tenantId);
            emit(state.copyWith(availableCoupons: coupons));
          } catch (_) {}
        },
        selectCoupon: (e) async {
          final coupon = e.coupon;
          if (coupon == null) {
            emit(state.copyWith(selectedCoupon: null, couponDiscount: 0));
            return;
          }
          final base = state.reservation.services
              .fold(0.0, (s, it) => s + it.price);
          final est = coupon.discountType == 'percentage'
              ? base * (coupon.discountValue / 100.0)
              : coupon.discountValue;
          final discount = est.clamp(0.0, base).toDouble();
          emit(state.copyWith(selectedCoupon: coupon, couponDiscount: discount));
        },
        confirmReservation: (e) async {
          final center = state.reservation.center;
          final service = state.reservation.services.isNotEmpty
              ? state.reservation.services.first
              : null;
          final barberId = state.effectiveBarberId;
          final startUtc = state.selectedSlotUtc;
          if (center == null ||
              service == null ||
              barberId == null ||
              startUtc == null) {
            emit(state.copyWith(
              status: ReservationStatus.failure,
              errorMessage: 'Faltan datos de la reserva.',
            ));
            return;
          }
          if (e.customerPhone.isEmpty) {
            emit(state.copyWith(
              status: ReservationStatus.failure,
              errorMessage: 'Agrega tu WhatsApp en tu perfil para reservar.',
            ));
            return;
          }
          final key = state.idempotencyKey ?? _genKey();
          emit(state.copyWith(
            status: ReservationStatus.loading,
            idempotencyKey: key,
            errorMessage: null,
          ));
          try {
            final result = await _repository.createBooking(
              tenantId: center.tenantId,
              branchId: center.id,
              barberId: barberId,
              serviceId: service.id,
              startUtc: startUtc,
              customerName: e.customerName,
              customerPhone: e.customerPhone,
              idempotencyKey: key,
              couponCode: state.selectedCoupon?.code,
            );
            emit(state.copyWith(
              status: ReservationStatus.success,
              reservation: state.reservation.copyWith(id: result.reservationId),
              finalPrice: result.finalPrice > 0 ? result.finalPrice : null,
              couponDiscount: result.discount,
            ));
          } catch (err) {
            emit(state.copyWith(
              status: ReservationStatus.failure,
              errorMessage: _friendlyError(err),
            ));
          }
        },
        activateDiscount: (e) async {
          final basePrice =
              state.reservation.services.fold(0.0, (sum, item) => sum + item.price);
          emit(state.copyWith(
            isDiscountActive: true,
            reservation: state.reservation.copyWith(totalPrice: basePrice * 0.5),
          ));
        },
        deactivateDiscount: (e) async {
          final basePrice =
              state.reservation.services.fold(0.0, (sum, item) => sum + item.price);
          emit(state.copyWith(
            isDiscountActive: false,
            reservation: state.reservation.copyWith(totalPrice: basePrice),
          ));
        },
        reset: (e) async {
          emit(const ReservationState(
            reservation: Reservation(tenantId: ''),
            isDiscountActive: false,
          ));
        },
      );
    });
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _genKey() {
    final rng = Random();
    final ts = DateTime.now().microsecondsSinceEpoch;
    final rand =
        List.generate(12, (_) => rng.nextInt(16).toRadixString(16)).join();
    return 'mob-$ts-$rand';
  }

  String _friendlyError(Object err) {
    final s = err.toString().toLowerCase();
    if (s.contains('slot_taken')) {
      return 'Ese horario se acaba de ocupar. Elige otro, por favor.';
    }
    if (s.contains('coupon_not_found')) {
      return 'Ese cupón no es válido para tu cuenta.';
    }
    if (s.contains('coupon_already_redeemed')) {
      return 'Ese cupón ya fue canjeado.';
    }
    if (s.contains('coupon_expired')) {
      return 'Tu cupón está vencido.';
    }
    if (s.contains('coupon_not_yet_valid')) {
      return 'Tu cupón aún no está disponible.';
    }
    if (s.contains('promotion_archived')) {
      return 'Esa promoción ya no está activa.';
    }
    if (s.contains('invalid_customer_input')) {
      return 'Faltan tus datos de contacto.';
    }
    if (s.contains('barber_not_in_branch') ||
        s.contains('branch_not_bookable') ||
        s.contains('branch_not_in_tenant') ||
        s.contains('service_not_in_tenant')) {
      return 'Esa opcion ya no esta disponible. Vuelve a elegir.';
    }
    return 'No se pudo crear la reserva. Intenta de nuevo.';
  }
}
