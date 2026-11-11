// Hits the real jsonplaceholder.typicode.com. Run on its own:
// flutter test test/live_test.dart --tags live
@Tags(['live'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user_repository.dart';

void main() {
  final repo = UserRepository(ApiClient(http.Client()));

  test('getAll, getById(999), create', () async {
    final all = await repo.getAll();
    expect(all, hasLength(10));
    await expectLater(repo.getById(999), throwsA(isA<NotFoundException>()));
    expect((await repo.create(all.first)).id, 11);
  });

  Future<Duration> timeToFail(String host) async {
    final sw = Stopwatch()..start();
    await expectLater(
      UserRepository(ApiClient(http.Client(), host: host)).getAll(),
      throwsA(isA<NoConnectionException>()),
    );
    // ignore: avoid_print
    print('$host -> NoConnectionException after ${sw.elapsedMilliseconds} ms');
    return sw.elapsed;
  }

  test('a typo host fails fast', () async {
    expect(
      await timeToFail('jsonplaceholder.typicode.co'),
      lessThan(const Duration(seconds: 3)),
    );
  });

  // The "Wi-Fi that leads nowhere": a socket that accepts and never answers.
  test('a black hole fails at the timeout', () async {
    final hole = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final held = <Socket>[];
    hole.listen(held.add);
    final t = await timeToFail('127.0.0.1:${hole.port}');
    expect(t.inSeconds, inInclusiveRange(9, 12));
    for (final s in held) {
      s.destroy();
    }
    await hole.close();
  }, timeout: const Timeout(Duration(seconds: 30)));
}
