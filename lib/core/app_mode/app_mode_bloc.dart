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

  AppModeBloc(this._authService) : super(const AppModeState()) {
    on<Initialize>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('access_code');
      
      if (savedCode != null && _authService.currentUser != null) {
        // Restaurar estado si ya hay sesión y código
        emit(state.copyWith(accessCode: savedCode, isLoggedIn: true));
        if (savedCode == '1') {
          emit(state.copyWith(mode: AppMode.client, isInitialized: true));
        }
      }
    });

    _authService.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        add(const AppModeEvent.login());
      } else {
        add(const AppModeEvent.logout());
      }
    });

    on<LoginWithGoogle>((event, emit) async {
      await _authService.signInWithGoogle();
    });
    on<ChangeMode>((event, emit) {
      if (event.mode == AppMode.barber) {
        if (!GetIt.I.hasScope('barber')) {
          GetIt.I.pushNewScope(scopeName: 'barber');
          // Aquí registrarías dependencias específicas de barbero si las hubiera
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
      } else {
        emit(state.copyWith(isLoggedIn: true));
      }
    });

    on<RequestLogout>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_code');
      await _authService.signOut();
    });

    on<Logout>((event, emit) async {
      if (GetIt.I.hasScope('barber')) {
        GetIt.I.popScope();
      }
      emit(const AppModeState());
    });

    on<Reset>((event, emit) {
      emit(const AppModeState());
    });
  }
}
