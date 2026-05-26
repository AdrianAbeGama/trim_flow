import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'package:core/core.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/app_mode/app_mode_state.dart';
import 'package:trim_flow/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AppModeBloc extends Bloc<AppModeEvent, AppModeState> {
  final AuthService _authService;
  bool _isLoggingOut = false;

  AppModeBloc(this._authService) : super(const AppModeState()) {
    on<Initialize>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('access_code');
      
      if (savedCode != null) {
        if (_authService.currentUser != null) {
          // Ya ingresó código y ya inició sesión con Google
          if (savedCode == '1') {
            emit(state.copyWith(accessCode: savedCode, isLoggedIn: true, mode: AppMode.client, isInitialized: true));
          } else if (savedCode == '2') {
            if (!GetIt.I.hasScope('barber')) {
              GetIt.I.pushNewScope(scopeName: 'barber');
            }
            emit(state.copyWith(accessCode: savedCode, isLoggedIn: true, mode: AppMode.barber, isInitialized: true));
          } else {
            emit(state.copyWith(accessCode: savedCode, isLoggedIn: true, isInitialized: true));
          }
        } else {
          // Ya ingresó código pero NO ha iniciado sesión con Google aún
          emit(state.copyWith(accessCode: savedCode, isLoggedIn: false, isInitialized: true));
        }
      } else {
        // No tiene código ingresado aún
        emit(state.copyWith(accessCode: null, isLoggedIn: false, isInitialized: true));
      }
    });

    _authService.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        add(const AppModeEvent.login());
      } else {
        if (!_isLoggingOut) {
          add(const AppModeEvent.logout());
        }
      }
    });

    on<LoginWithGoogle>((event, emit) async {
      emit(state.copyWith(isInitialized: false));
      await _authService.signInWithGoogle();
    });
    on<ChangeMode>((event, emit) {
      if (event.mode == AppMode.barber) {
        if (!GetIt.I.hasScope('barber')) {
          GetIt.I.pushNewScope(scopeName: 'barber');
        }
      }
      emit(state.copyWith(mode: event.mode, isInitialized: true));
    });

    on<SetAccessCode>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_code', event.code);
      emit(state.copyWith(accessCode: event.code));
    });

    on<Login>((event, emit) {
      if (state.accessCode == '1') {
        emit(state.copyWith(isLoggedIn: true, mode: AppMode.client, isInitialized: true));
      } else if (state.accessCode == '2') {
        if (!GetIt.I.hasScope('barber')) {
          GetIt.I.pushNewScope(scopeName: 'barber');
        }
        emit(state.copyWith(isLoggedIn: true, mode: AppMode.barber, isInitialized: true));
      } else {
        emit(state.copyWith(isLoggedIn: true, isInitialized: true));
      }
    });

    on<RequestLogout>((event, emit) async {
      _isLoggingOut = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_code');
      if (GetIt.I.hasScope('barber')) {
        GetIt.I.popScope();
      }
      await _authService.signOut();
      emit(const AppModeState(isInitialized: true));
      _isLoggingOut = false;
    });

    on<Logout>((event, emit) async {
      if (GetIt.I.hasScope('barber')) {
        GetIt.I.popScope();
      }
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('access_code');
      emit(AppModeState(
        accessCode: savedCode ?? state.accessCode,
        isLoggedIn: false,
        isInitialized: true,
      ));
    });

    on<Reset>((event, emit) {
      emit(const AppModeState());
    });
  }
}
