import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, {this._token}); // callers pass `token:`

  final SecureStore _store;
  String? _token;

  bool get signedIn => _token != null;

  /// Only for the debug-only "Copy token" button. Never print it.
  String? get token => _token;

  /// Fake server: any password of 8+ characters gets a token after a second.
  Future<void> login(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (password.length < 8) {
      throw const FormatException('Wrong email or password');
    }
    final token = 'tok_${email.hashCode}';
    await _store.saveToken(token);
    _token = token;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    _token = null;
    notifyListeners();
  }
}
