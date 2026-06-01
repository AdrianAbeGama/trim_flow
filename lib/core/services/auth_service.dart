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

  Future<void> signOut() async {
    await _supabase.auth.signOut(scope: SignOutScope.global);
  }
}
