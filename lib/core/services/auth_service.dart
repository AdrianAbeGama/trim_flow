import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.trimflow://login-callback',
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
