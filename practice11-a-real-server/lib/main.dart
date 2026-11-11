import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/api/api_exception.dart';
import 'features/users/user.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

// User 1, pasted from the real response.
const _user1 = r'''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {"lat": "-37.3159", "lng": "81.1496"}
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
''';

/// Levels 2 and 3 checks, before any screen:
/// flutter run -d windows --dart-define=CHECKS=true
Future<void> _checks(UserRepository repo) async {
  final u = User.fromJson(jsonDecode(_user1) as Map<String, dynamic>);
  debugPrint('$u lat=${u.address.geo.lat} digits=${u.phoneDigits}');

  final all = await repo.getAll();
  debugPrint('${all.length} users: ${all.map((u) => u.name).join(', ')}');
  try {
    await repo.getById(999);
  } on NotFoundException {
    debugPrint('not found');
  }
  final created = await repo.create(u);
  debugPrint('created id ${created.id}');
}

Future<void> main() async {
  // The composition root: the only place that builds an http client.
  final repo = UserRepository(ApiClient(Client()));
  if (const bool.fromEnvironment('CHECKS')) await _checks(repo);
  runApp(
    ChangeNotifierProvider(
      create: (_) => UsersModel(repo)..load(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users',
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: const UsersScreen(),
    );
  }
}
