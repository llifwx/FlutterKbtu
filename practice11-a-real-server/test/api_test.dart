import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';

const _user1 = {
  'id': 1,
  'name': 'Leanne Graham',
  'username': 'Bret',
  'email': 'Sincere@april.biz',
  'address': {
    'street': 'Kulas Light',
    'suite': 'Apt. 556',
    'city': 'Gwenborough',
    'zipcode': '92998-3874',
    'geo': {'lat': '-37.3159', 'lng': '81.1496'},
  },
  'phone': '1-770-736-8031 x56442',
  'website': 'hildegard.org',
  'company': {'name': 'Romaguera-Crona', 'catchPhrase': 'Multi-layered'},
};

UserRepository _repo(int status, String body) => UserRepository(
  ApiClient(MockClient((_) async => http.Response(body, status))),
);

void main() {
  test('fromJson/toJson round-trip keeps every field', () {
    final u = User.fromJson(_user1);
    expect(u.address.geo.lat, -37.3159);
    expect(u.phoneDigits, '1770736803156442');
    final back = User.fromJson(u.toJson());
    expect(back, u);
    expect(jsonEncode(back.toJson()), jsonEncode(u.toJson()));
  });

  test('status is checked before the body', () async {
    expect(_repo(404, '{}').getById(999), throwsA(isA<NotFoundException>()));
    expect(_repo(401, '{}').getAll(), throwsA(isA<UnauthorizedException>()));
    expect(
      _repo(503, '').getAll(),
      throwsA(isA<ServerException>().having((e) => e.status, 'status', 503)),
    );
  });

  test('bad JSON and bad casts become BadResponseException', () async {
    expect(_repo(200, '<html>').getAll(), throwsA(isA<BadResponseException>()));
    final wrongId = {..._user1, 'id': '1'};
    expect(
      _repo(200, jsonEncode(wrongId)).getById(1),
      throwsA(isA<BadResponseException>()),
    );
  });

  test('no network becomes NoConnectionException', () async {
    final repo = UserRepository(
      ApiClient(MockClient((_) => throw const SocketException('down'))),
    );
    expect(repo.getAll(), throwsA(isA<NoConnectionException>()));
  });
}
