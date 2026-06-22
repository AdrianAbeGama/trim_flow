import 'package:core/core.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/widgets/home_screen/home_widget_keys.dart';
import 'package:trim_flow/features/profile/domain/repositories/profile_repository.dart';

/// Barberia del cliente: id + nombre, para etiquetar la cita en el widget.
class TenantRef {
  const TenantRef({required this.id, required this.name});
  final String id;
  final String name;
}

/// Empuja al widget de Android (app cliente) la "proxima cita" mas cercana
/// ENTRE TODAS las barberias del cliente, con el nombre de la barberia.
/// Best-effort: nunca lanza ni bloquea el flujo de la app.
class ClientWidgetService {
  const ClientWidgetService();

  Future<void> refresh({
    required ProfileRepository repository,
    required List<TenantRef> tenants,
    int loyaltyHave = 0,
    int loyaltyNeed = 0,
  }) async {
    if (tenants.isEmpty) return;
    try {
      // Una lectura por barberia (1-3 tipicamente), cada una protegida.
      final results = await Future.wait(tenants.map((t) async {
        try {
          final res = await repository.loadMyReservations(tenantId: t.id);
          final next = res.upcoming.isNotEmpty ? res.upcoming.first : null;
          if (next == null) return null;
          return (reservation: next, tenantName: t.name);
        } catch (_) {
          return null;
        }
      }));

      final candidates = results
          .whereType<({Reservation reservation, String tenantName})>()
          .where((c) => c.reservation.date != null)
          .toList()
        ..sort((a, b) => a.reservation.date!.compareTo(b.reservation.date!));

      final best = candidates.isEmpty ? null : candidates.first;
      await _push(best?.reservation,
          barbershopName: best?.tenantName,
          loyaltyHave: loyaltyHave,
          loyaltyNeed: loyaltyNeed);
    } catch (_) {
      // best-effort
    }
  }

  Future<void> _push(
    Reservation? next, {
    String? barbershopName,
    int loyaltyHave = 0,
    int loyaltyNeed = 0,
  }) async {
    // Fidelidad (independiente de la cita): cortes en el ciclo y cuantos faltan.
    final inCycle = loyaltyNeed > 0 ? loyaltyHave % loyaltyNeed : loyaltyHave;
    final left = loyaltyNeed > 0 ? loyaltyNeed - inCycle : 0;
    await Future.wait([
      HomeWidget.saveWidgetData<String>('client_loyalty_have', '$inCycle'),
      HomeWidget.saveWidgetData<String>('client_loyalty_need', '$loyaltyNeed'),
      HomeWidget.saveWidgetData<String>('client_loyalty_left', '$left'),
    ]);

    if (next == null) {
      await HomeWidget.saveWidgetData<String>('client_time', '');
    } else {
      final service =
          next.services.isNotEmpty ? next.services.first.name : 'Servicio';
      final barber = next.professional?.name;
      final date = next.date?.toLocal();
      final dateCap =
          date != null ? _cap(DateFormat('EEE d MMM', 'es').format(date)) : '';
      final shop = barbershopName ?? next.center?.name ?? 'Tu barbería';
      final line1 = barber != null ? '$service · con $barber' : service;
      final line2 = dateCap.isEmpty ? shop : '$shop · $dateCap';
      await Future.wait([
        HomeWidget.saveWidgetData<String>('client_time', next.time ?? ''),
        HomeWidget.saveWidgetData<String>('client_line1', line1),
        HomeWidget.saveWidgetData<String>('client_line2', line2),
        HomeWidget.saveWidgetData<String>(
            'client_target_ms', '${next.date?.millisecondsSinceEpoch ?? 0}'),
        HomeWidget.saveWidgetData<String>(
            'client_day', date != null ? '${date.day}' : ''),
        HomeWidget.saveWidgetData<String>(
            'client_weekday', date != null ? _weekday(date) : ''),
      ]);
    }

    for (final provider in HomeWidgetNames.clientProviders) {
      await HomeWidget.updateWidget(qualifiedAndroidName: provider);
    }
  }

  String _weekday(DateTime d) {
    const w = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    return w[(d.weekday - 1) % 7];
  }

  String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
