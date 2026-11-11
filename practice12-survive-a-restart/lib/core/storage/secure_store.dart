import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keychain (iOS) / Keystore-encrypted storage (Android). Never prefs.
class SecureStore {
  const SecureStore();

  static const _storage = FlutterSecureStorage();
  static const _key = 'token';

  Future<void> saveToken(String token) =>
      _storage.write(key: _key, value: token);

  Future<String?> readToken() => _storage.read(key: _key);

  Future<void> clear() => _storage.delete(key: _key);
}
