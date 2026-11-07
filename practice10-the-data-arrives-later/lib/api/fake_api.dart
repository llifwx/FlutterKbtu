import 'package:flutter/foundation.dart';

class Student {
  const Student({required this.name, required this.group, this.gpa});
  final String name;
  final String group;
  final double? gpa;
}

class NoConnectionException implements Exception {}

const _seed = [
  Student(name: 'Aida Nurlanova', group: 'IT-2301', gpa: 3.7),
  Student(name: 'Dias Seitkali', group: 'IT-2301', gpa: 3.1),
  Student(name: 'Aruzhan Bek', group: 'IT-2302'),
  Student(name: 'Timur Alibekov', group: 'IT-2302', gpa: 2.9),
  Student(name: 'Dana Omarova', group: 'IT-2303', gpa: 3.9),
  Student(name: 'Alikhan Kairatuly', group: 'IT-2303', gpa: 3.4),
];

// Level 1: the API that does not exist yet. It must feel like a
// network: slow, and sometimes down.
class FakeApi {
  FakeApi({this.empty = false});
  final bool empty; // true -> the server has no students
  int calls = 0; // how many times fetchStudents() ran
  // Static: the "server" counts saves across screens, so the second save
  // fails even though a successful one popped the first screen.
  static int _saves = 0;

  Future<List<Student>> fetchStudents() async {
    // Read the number before the await: by the time the delay ends, parallel
    // calls have already bumped `calls`, and all three would fail together.
    final call = ++calls;
    debugPrint('fetchStudents #$call');
    await Future.delayed(const Duration(seconds: 2));
    if (call % 3 == 0) throw NoConnectionException();
    return empty ? const [] : _seed;
  }

  Future<void> save(int value) async {
    _saves++;
    await Future.delayed(const Duration(seconds: 1));
    if (_saves.isEven) throw StateError('server rejected $value');
  }
}
