import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Uri _uri(String path) => Uri.https(_api.host, path);

  Future<List<User>> getAll() async {
    final json = await _api.request(
      (http.Client c) => c.get(_uri('/users'), headers: _api.headers),
    );
    return _parse(
      'users',
      () => [
        for (final u in json as List<dynamic>)
          User.fromJson(u as Map<String, dynamic>),
      ],
    );
  }

  Future<User> getById(int id) async {
    final json = await _api.request(
      (http.Client c) => c.get(_uri('/users/$id'), headers: _api.headers),
    );
    return _parse(
      'users/$id',
      () => User.fromJson(json as Map<String, dynamic>),
    );
  }

  /// JSONPlaceholder echoes the body back with its own id (always 11).
  Future<User> create(User draft) async {
    final json = await _api.request(
      (http.Client c) => c.post(
        _uri('/users'),
        headers: {..._api.headers, 'Content-Type': 'application/json'},
        body: jsonEncode(draft.toJson()),
      ),
      expect: 201,
    );
    return _parse(
      'POST users',
      () => User.fromJson(json as Map<String, dynamic>),
    );
  }

  // A failed cast or parse names the field; keep the message, make it ours.
  T _parse<T>(String where, T Function() build) {
    try {
      return build();
    } on TypeError catch (e) {
      throw BadResponseException('$where: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$where: $e');
    }
  }
}
