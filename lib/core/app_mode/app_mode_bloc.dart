import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/app_mode/app_mode_state.dart';
import 'package:trim_flow/core/services/auth_service.dart';

const String _kAccessCodeKey = 'access_code';
const String _kAppModeKey = 'app_mode';
const String _kBarberScope = 'barber';

@lazySingleton
class AppModeBloc extends Bloc<AppModeEvent, AppModeState> {
  final AuthService _authService;

  String? _lastKnownUserId;
  StreamSubscription<supa.AuthState>? _authSub;

  AppModeBloc(this._authService) : super(const AppModeState()) {
    _lastKnownUserId = _authService.currentUser?.id;

    on<Initialize>(_onInitialize);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<ChangeMode>(_onChangeMode);
    on<SetAccessCode>(_onSetAccessCode);
    on<Login>(_onLogin);
    on<PasswordRecoveryStarted>(_onPasswordRecoveryStarted);
    on<PasswordRecoveryFinished>(_onPasswordRecoveryFinished);
    on<RequestLogout>(_onRequestLogout);
    on<Logout>(_onLogout);
    on<Reset>(_onReset);

    _authSub = _authService.onAuthStateChange.listen(_onAuthChanged);
  }

  void _onAuthChanged(supa.AuthState data) {
    // Link de "olvide mi contrasena": la app se abre con un evento de recovery.
    // Mostramos la pantalla de nueva clave en vez de entrar directo.
    if (data.event == supa.AuthChangeEvent.passwordRecovery) {
      _lastKnownUserId = data.session?.user.id;
      add(const AppModeEvent.passwordRecoveryStarted());
      return;
    }

    final newUserId = data.session?.user.id;
    final previous = _lastKnownUserId;
    _lastKnownUserId = newUserId;

    if (newUserId != null && newUserId != previous) {
      add(const AppModeEvent.login());
      return;
    }

    if (newUserId == null && previous != null) {
      add(const AppModeEvent.logout());
    }
  }

  Future<void> _onInitialize(Initialize event, Emitter<AppModeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_kAccessCodeKey);
    final resolvedMode = await _resolveStoredMode(prefs, savedCode);

    final currentUser = _authService.currentUser;
    _lastKnownUserId = currentUser?.id;

    if (currentUser == null) {
      emit(state.copyWith(accessCode: savedCode, isLoggedIn: false, isInitialized: true));
      return;
    }

    if (resolvedMode == AppMode.barber) {
      _ensureBarberScope();
      emit(state.copyWith(
        accessCode: savedCode,
        isLoggedIn: true,
        mode: AppMode.barber,
        isInitialized: true,
      ));
    } else if (resolvedMode == AppMode.client) {
      emit(state.copyWith(
        accessCode: savedCode,
        isLoggedIn: true,
        mode: AppMode.client,
        isInitialized: true,
      ));
    } else {
      emit(state.copyWith(
        accessCode: savedCode,
        isLoggedIn: true,
        isInitialized: true,
      ));
    }
  }

  Future<void> _onLoginWithGoogle(LoginWithGoogle event, Emitter<AppModeState> emit) async {
    await _authService.signInWithGoogle();
  }

  void _onChangeMode(ChangeMode event, Emitter<AppModeState> emit) {
    if (event.mode == AppMode.barber) {
      _ensureBarberScope();
    }
    emit(state.copyWith(mode: event.mode, isInitialized: true));
    _persistMode(event.mode);
  }

  Future<void> _onSetAccessCode(SetAccessCode event, Emitter<AppModeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessCodeKey, event.code);

    final derivedMode = _mapLegacyCodeToMode(event.code);
    if (derivedMode != null) {
      await prefs.setString(_kAppModeKey, derivedMode.name);
    }

    emit(state.copyWith(accessCode: event.code));
  }

  Future<void> _onLogin(Login event, Emitter<AppModeState> emit) async {
    if (state.isLoggedIn && state.mode != null && state.isInitialized) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final resolvedMode = await _resolveStoredMode(prefs, state.accessCode);

    if (resolvedMode == AppMode.barber) {
      _ensureBarberScope();
      emit(state.copyWith(isLoggedIn: true, mode: AppMode.barber, isInitialized: true));
    } else if (resolvedMode == AppMode.client) {
      emit(state.copyWith(isLoggedIn: true, mode: AppMode.client, isInitialized: true));
    } else {
      emit(state.copyWith(isLoggedIn: true, isInitialized: true));
    }
  }

  void _onPasswordRecoveryStarted(
      PasswordRecoveryStarted event, Emitter<AppModeState> emit) {
    emit(state.copyWith(isPasswordRecovery: true, isInitialized: true));
  }

  Future<void> _onPasswordRecoveryFinished(
      PasswordRecoveryFinished event, Emitter<AppModeState> emit) async {
    emit(state.copyWith(isPasswordRecovery: false));
    add(const AppModeEvent.login());
  }

  Future<void> _onRequestLogout(RequestLogout event, Emitter<AppModeState> emit) async {
    // Emite el nuevo estado INMEDIATAMENTE para que la UI reaccione (sin
    // esperar a la red). Si signOut tarda, el usuario ya está en AccessCode.
    _lastKnownUserId = null;
    emit(const AppModeState(isInitialized: true));

    // Limpia prefs y scope DI (rápido, local).
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kAccessCodeKey);
      await prefs.remove(_kAppModeKey);
    } catch (_) {/* prefs falló, no bloquea logout local */}

    if (GetIt.I.hasScope(_kBarberScope)) {
      try { GetIt.I.popScope(); } catch (_) {}
    }

    // signOut a Supabase con timeout — si la red falla, el logout local
    // ya está hecho (estado emitido arriba).
    try {
      await _authService.signOut().timeout(const Duration(seconds: 4));
    } catch (e) {
      // Logout local hecho; si Supabase no respondió, no rompemos UX.
    }
  }

  Future<void> _onLogout(Logout event, Emitter<AppModeState> emit) async {
    if (GetIt.I.hasScope(_kBarberScope)) {
      GetIt.I.popScope();
    }
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_kAccessCodeKey);
    final savedMode = _readPersistedMode(prefs);
    emit(AppModeState(
      accessCode: savedCode ?? state.accessCode,
      mode: savedMode ?? state.mode,
      isLoggedIn: false,
      isInitialized: true,
    ));
  }

  void _onReset(Reset event, Emitter<AppModeState> emit) {
    emit(const AppModeState());
  }

  Future<AppMode?> _resolveStoredMode(SharedPreferences prefs, String? legacyCode) async {
    final persisted = _readPersistedMode(prefs);
    if (persisted != null) return persisted;

    if (legacyCode == null) return null;
    final migrated = _mapLegacyCodeToMode(legacyCode);
    if (migrated != null) {
      await prefs.setString(_kAppModeKey, migrated.name);
    }
    return migrated;
  }

  AppMode? _readPersistedMode(SharedPreferences prefs) {
    final raw = prefs.getString(_kAppModeKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AppMode.values.byName(raw);
    } catch (_) {
      return null;
    }
  }

  AppMode? _mapLegacyCodeToMode(String code) {
    switch (code) {
      case '1':
        return AppMode.client;
      case '2':
        return AppMode.barber;
      default:
        return null;
    }
  }

  Future<void> _persistMode(AppMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAppModeKey, mode.name);
  }

  void _ensureBarberScope() {
    if (!GetIt.I.hasScope(_kBarberScope)) {
      GetIt.I.pushNewScope(scopeName: _kBarberScope);
    }
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    return super.close();
  }
}
