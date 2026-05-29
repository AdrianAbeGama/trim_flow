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

  Stream<void> watchChanges({required String barberId});
}
