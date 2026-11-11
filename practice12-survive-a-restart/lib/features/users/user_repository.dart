import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

typedef UsersResult = ({List<User> items, bool fromCache});

class UserRepository {
  UserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  Uri _uri(String path) => Uri.https(_api.host, path);

  /// Fresh from the server, or the last good list when there is no network.
  Future<UsersResult> getAll() async {
    try {
      final fresh = await _fetchAll();
      await _cache.save(fresh);
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<List<User>> _fetchAll() async {
    final json = await _api.request(
      (http.Client c) async =>
          c.get(_uri('/users'), headers: await _api.headers()),
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
      (http.Client c) async =>
          c.get(_uri('/users/$id'), headers: await _api.headers()),
    );
    return _parse(
      'users/$id',
      () => User.fromJson(json as Map<String, dynamic>),
    );
  }

  /// JSONPlaceholder echoes the body back with its own id (always 11).
  Future<User> create(User draft) async {
    final json = await _api.request(
      (http.Client c) async => c.post(
        _uri('/users'),
        headers: {...await _api.headers(), 'Content-Type': 'application/json'},
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
