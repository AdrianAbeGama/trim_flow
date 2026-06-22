import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/widgets/home_screen/home_widget_keys.dart';

/// Empuja el "resumen de hoy" del barbero al widget de Android (app barbero).
/// Es best-effort: nunca lanza ni bloquea el flujo de la app.
class BarberWidgetService {
  const BarberWidgetService();

  Future<void> push({
    required int cuts,
    required double revenue,
    DateTime? nextStart,
  }) async {
    final cortes = cuts == 1 ? '1 corte' : '$cuts cortes';
    final summary = '$cortes · S/ ${revenue.toStringAsFixed(0)}';
    final next = nextStart != null
        ? 'Próxima cita ${DateFormat('HH:mm').format(nextStart.toLocal())}'
        : 'Sin próximas citas';
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String>('barber_summary', summary),
        HomeWidget.saveWidgetData<String>('barber_next', next),
      ]);
      await HomeWidget.updateWidget(
        qualifiedAndroidName: HomeWidgetNames.barberProvider,
      );
    } catch (_) {
      // Widget best-effort: si falla (p. ej. iOS sin configurar), se ignora.
    }
  }
}
