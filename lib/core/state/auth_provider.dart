import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/vira_session.dart';

/// Holds the current session in memory and mirrors role/token to
/// SharedPreferences so ApiClient's interceptor and app restarts can
/// recover it without re-authenticating every cold start.
class AuthNotifier extends StateNotifier<ViraSession?> {
  AuthNotifier() : super(null) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('vira_session_token');
    if (token == null) return;
    // In production: validate token against /v1/auth/me and rehydrate
    // the full ViraSession from the response. Stubbed here since this
    // scaffold has no live backend to call yet.
  }

  Future<void> signIn(ViraSession session, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vira_session_token', token);
    await prefs.setString('vira_role', session.role.name);
    state = session;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vira_session_token');
    await prefs.remove('vira_role');
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, ViraSession?>(
  (ref) => AuthNotifier(),
);

/// Convenience derived provider — most UI just needs to know "are we
/// logged in," not the full session object.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) != null;
});
