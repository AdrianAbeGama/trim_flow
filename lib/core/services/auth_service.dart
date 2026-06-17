import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/app_mode/bootstrap_mode.dart';

@lazySingleton
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: currentBootstrapMode.oauthRedirectUrl,
      queryParams: const {
        'prompt': 'select_account',
        'access_type': 'offline',
      },
    );
  }

  /// Envia un codigo OTP de un solo uso al correo (login sin contrasena).
  Future<void> sendEmailOtp(String email) async {
    await _supabase.auth.signInWithOtp(email: email);
  }

  /// Verifica el codigo OTP. Al validar, Supabase abre la sesion y
  /// onAuthStateChange notifica el login (lo maneja AppModeBloc).
  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut(scope: SignOutScope.global);
  }
}
