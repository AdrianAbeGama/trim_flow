import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estilo de ticket: siempre blanco. (La opción de "ticket oscuro" se retiró;
/// se mantiene el notificador para no romper los widgets que lo leen.)
class TicketStyle {
  TicketStyle._();

  static const _key = 'ui_ticket_dark';

  static final ValueNotifier<bool> dark = ValueNotifier<bool>(false);

  static Future<void> load() async {
    dark.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
  }
}
