import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:trim_flow/core/notifications/notifications.dart';

/// Programa recordatorios locales para una cita.
/// - 24h antes: "Mañana a las {hora} tienes tu corte"
/// - 1h antes: "En 1 hora: {servicio} con {barbero}"
///
/// Los IDs se derivan del hash del reservation ID para que se puedan
/// cancelar luego si la cita es modificada o cancelada.
class AppointmentReminders {
  AppointmentReminders._();

  static const String _channelId = 'trimflow_reminders';
  static const String _channelName = 'Recordatorios de Cita';
  static const String _channelDesc = 'Notificaciones para tus reservas próximas';

  /// Programa los 2 recordatorios (24h + 1h) para una cita.
  /// Si el horario ya pasó, no se programa nada.
  static Future<void> schedule({
    required String reservationId,
    required DateTime appointmentDateTime,
    required String serviceName,
    required String barberName,
  }) async {
    final now = DateTime.now();
    if (appointmentDateTime.isBefore(now)) return;

    final ids = _idsFromReservation(reservationId);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    final twentyFourHoursBefore = appointmentDateTime.subtract(const Duration(hours: 24));
    final oneHourBefore = appointmentDateTime.subtract(const Duration(hours: 1));

    try {
      if (twentyFourHoursBefore.isAfter(now)) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: ids.dayBefore,
          title: 'Tu corte es mañana',
          body: 'A las ${_formatTime(appointmentDateTime)} con $barberName · $serviceName',
          scheduledDate: tz.TZDateTime.from(twentyFourHoursBefore, tz.local),
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }

      if (oneHourBefore.isAfter(now)) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: ids.hourBefore,
          title: 'En 1 hora: $serviceName',
          body: 'Recuerda llegar 5 min antes a tu cita con $barberName',
          scheduledDate: tz.TZDateTime.from(oneHourBefore, tz.local),
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e, stack) {
      debugPrint('AppointmentReminders.schedule failed: $e\n$stack');
    }
  }

  /// Cancela ambos recordatorios programados para una cita.
  static Future<void> cancel(String reservationId) async {
    final ids = _idsFromReservation(reservationId);
    try {
      await flutterLocalNotificationsPlugin.cancel(id: ids.dayBefore);
      await flutterLocalNotificationsPlugin.cancel(id: ids.hourBefore);
    } catch (e) {
      debugPrint('AppointmentReminders.cancel failed: $e');
    }
  }

  static ({int dayBefore, int hourBefore}) _idsFromReservation(String reservationId) {
    // Hash determinista del ID → 2 IDs distintos por cita (24h y 1h)
    final base = reservationId.hashCode & 0x3fffffff;
    return (dayBefore: base, hourBefore: base ^ 0x7);
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
