import 'package:flutter/foundation.dart';

/// Señal global: el widget de Android del barbero pidió abrir el walk-in.
///
/// La pone [BarberHomePage] al recibir el deep link del widget y la consume la
/// vista de agenda (que es la que tiene el [AgendaBloc] para abrir el sheet).
final ValueNotifier<bool> walkInPending = ValueNotifier<bool>(false);
