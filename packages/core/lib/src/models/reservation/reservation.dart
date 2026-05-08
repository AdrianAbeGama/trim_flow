import 'package:freezed_annotation/freezed_annotation.dart';
import 'center.dart';
import 'professional.dart';
import 'service.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

@freezed
abstract class Reservation with _$Reservation {
  const factory Reservation({
    required String tenantId,
    String? id,
    BarberCenter? center,
    @Default([]) List<Service> services,
    Professional? professional,
    DateTime? date,
    String? time,
    @Default(0.0) double totalPrice,
    @Default(0) int totalDurationInMinutes,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
}
