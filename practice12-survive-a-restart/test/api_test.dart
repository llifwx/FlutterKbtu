import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/core/storage/secure_store.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_cache.dart';

const user1 = {
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

late Directory tmp;

UserRepository repoWith(MockClientHandler handler) => UserRepository(
  ApiClient(MockClient(handler), const SecureStore()),
  UsersCache(() async => tmp),
);

UserRepository _repo(int status, String body) =>
    repoWith((_) async => http.Response(body, status));

Future<http.Response> _offline(http.Request _) =>
    throw const SocketException('down');

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    tmp = Directory.systemTemp.createTempSync('users_cache');
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  test('fromJson/toJson round-trip keeps every field', () {
    final u = User.fromJson(user1);
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
    expect(
      _repo(200, jsonEncode({...user1, 'id': '1'})).getById(1),
      throwsA(isA<BadResponseException>()),
    );
  });

  test('the token becomes a header only when there is one', () async {
    final seen = <String?>[];
    final repo = repoWith((r) async {
      seen.add(r.headers['Authorization']);
      return http.Response(jsonEncode([user1]), 200);
    });
    await repo.getAll();
    await const SecureStore().saveToken('tok_42');
    await repo.getAll();
    await const SecureStore().clear();
    await repo.getAll();
    expect(seen, [null, 'Bearer tok_42', null]);
  });

  test('offline with nothing saved: the honest error', () async {
    expect(repoWith(_offline).getAll(), throwsA(isA<NoConnectionException>()));
  });

  test('offline after one good load: the saved list, marked', () async {
    final online = await _repo(200, jsonEncode([user1])).getAll();
    expect(online.fromCache, isFalse);
    expect(File('${tmp.path}/users.json').existsSync(), isTrue);

    final offline = await repoWith(_offline).getAll();
    expect(offline.fromCache, isTrue);
    expect(offline.items.single.name, 'Leanne Graham');
  });
}
