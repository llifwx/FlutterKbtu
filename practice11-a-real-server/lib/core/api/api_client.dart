import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

// Lets main.dart build the one http.Client without importing package:http.
export 'package:http/http.dart' show Client;

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  static const timeout = Duration(seconds: 10);

  Map<String, String> get headers => const {'Accept': 'application/json'};

  /// Sends [call], checks the status before the body, returns decoded JSON.
  /// Anything that goes wrong leaves here as an [ApiException].
  Future<dynamic> request(
    Future<http.Response> Function(http.Client client) call, {
    int? expect,
  }) async {
    final r = await _send(() => call(_client));
    assert(() {
      log(
        '${r.request?.method} ${r.request?.url.path} → ${r.statusCode}',
        name: 'api',
      );
      return true;
    }()); // debug only: asserts are stripped from release builds
    _check(r);
    if (expect != null && r.statusCode != expect) {
      throw BadResponseException('expected $expect, got ${r.statusCode}');
    }
    return _decode(r);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(timeout);
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      // On web the browser reports a dead network as a ClientException.
      throw const NoConnectionException();
    }
  }

  void _check(http.Response r) {
    final s = r.statusCode;
    if (s == 401) throw const UnauthorizedException();
    if (s == 404) throw const NotFoundException();
    if (s >= 500) throw ServerException(s);
    if (s >= 400) throw BadResponseException('HTTP $s');
  }

  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException('${r.request?.url.path}: $e');
    }
  }
}
