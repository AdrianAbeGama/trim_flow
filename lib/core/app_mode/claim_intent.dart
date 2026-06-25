import 'package:flutter/foundation.dart';

/// Intencion transitoria del cliente de agregar OTRA barberia con codigo.
///
/// La activa el boton "otro negocio" del login y la consume el gate del cliente
/// para mostrar la pantalla de codigo aunque el usuario ya tenga barberias
/// vinculadas. Se limpia al vincular con exito, al volver, o en el login normal
/// con Google.
final ValueNotifier<bool> claimAnotherIntent = ValueNotifier<bool>(false);
