import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';

part 'agenda_repository.freezed.dart';

@freezed
abstract class WalkInRequest with _$WalkInRequest {
  const factory WalkInRequest({
    required String tenantId,
    required String branchId,
    required String barberId,
    required String serviceId,
    required DateTime startTime,
    required String customerName,
    required String customerPhone,
  }) = _WalkInRequest;
}

@freezed
abstract class AgendaLookupRefs with _$AgendaLookupRefs {
  const factory AgendaLookupRefs({
    String? defaultBranchId,
    String? defaultServiceId,
  }) = _AgendaLookupRefs;
}

/// Cupon usable de un cliente, para aplicar al completar el corte.
class AgendaCoupon {
  final String code;
  final String name;
  final String discountType;
  final double discountValue;

  const AgendaCoupon({
    required this.code,
    required this.name,
    required this.discountType,
    required this.discountValue,
  });

  String get label => discountType == 'percentage'
      ? '${discountValue.toStringAsFixed(0)}%'
      : 'S/ ${discountValue.toStringAsFixed(0)}';

  /// Descuento en soles sobre [price], acotado a [0, price].
  double discountFor(num price) {
    final p = price.toDouble();
    final raw = discountType == 'percentage' ? p * discountValue / 100 : discountValue;
    if (raw <= 0) return 0;
    return raw > p ? p : raw;
  }
}

/// Resumen del dia de HOY (independiente del dia que se este viendo) +
/// la proxima cita futura (global).
class AgendaTodaySummary {
  final int completedCuts;
  final double revenue;
  final DateTime? nextStart;

  const AgendaTodaySummary({
    this.completedCuts = 0,
    this.revenue = 0,
    this.nextStart,
  });
}

abstract class AgendaRepository {
  Future<List<AgendaAppointment>> fetchAgendaForDay({
    required String barberId,
    required DateTime day,
  });

  Future<AgendaLookupRefs> resolveDefaultRefs({
    required String barberId,
    required String tenantId,
  });

  Future<Map<String, dynamic>> registerWalkIn(WalkInRequest request);

  /// Completa el corte (status confirmed -> completed) via RPC atomica.
  /// [couponCode] opcional: aplica el cupon (descuento real en el ledger).
  Future<void> completeReservation({
    required String reservationId,
    required num amount,
    String? couponCode,
  });

  /// Cupones usables (activos, no canjeados, no vencidos) de un cliente.
  Future<List<AgendaCoupon>> fetchUsableCoupons({required String customerId});

  /// Marca no asistio (status confirmed -> no_show) via RPC atomica.
  Future<void> markNoShow({required String reservationId});

  /// Metricas de HOY (cortes completados + ingresos) y proxima cita futura.
  Future<AgendaTodaySummary> fetchTodaySummary({required String barberId});

  /// Dias (locales) con al menos una cita activa en el rango, para marcar el
  /// calendario.
  Future<List<DateTime>> fetchMarkedDays({
    required String barberId,
    required DateTime from,
    required DateTime to,
  });

  Stream<void> watchChanges({required String barberId});
}
