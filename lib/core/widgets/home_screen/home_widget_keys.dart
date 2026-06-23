/// Nombres calificados de los AppWidgetProviders nativos (Android).
///
/// Se usa el nombre CALIFICADO (con package) porque el applicationId del flavor
/// (com.trimflow.app / com.trimflow.business) difiere del package Kotlin
/// (com.example.trim_flow); un `androidName` sin calificar resolveria contra el
/// applicationId y fallaria.
class HomeWidgetNames {
  const HomeWidgetNames._();

  static const String _pkg = 'com.example.trim_flow.widgets';

  // Cliente (4 estilos, mismos datos).
  static const String clientProvider = '$_pkg.ClientNextAppointmentWidget';
  static const String clientCountdownProvider = '$_pkg.ClientCountdownWidget';
  static const String clientLoyaltyProvider = '$_pkg.ClientLoyaltyWidget';
  static const String clientDateProvider = '$_pkg.ClientDateBlockWidget';

  static const List<String> clientProviders = [
    clientCountdownProvider,
    clientLoyaltyProvider,
    clientDateProvider,
  ];

  // Barbero.
  static const String barberProvider = '$_pkg.BarberTodayWidget';
}
