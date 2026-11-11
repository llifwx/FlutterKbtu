import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';

/// The last good list, in Documents: the OS may wipe Temporary at any time.
class UsersCache {
  UsersCache([this._dir = getApplicationDocumentsDirectory]);

  final Future<Directory> Function() _dir;

  Future<File> get _file async => File('${(await _dir()).path}/users.json');

  Future<void> save(List<User> users) async {
    await (await _file).writeAsString(
      jsonEncode([for (final u in users) u.toJson()]),
    );
  }

  /// null when nothing was ever saved (or the file is unreadable).
  Future<List<User>?> load() async {
    final file = await _file;
    if (!await file.exists()) return null;
    try {
      return [
        for (final u in jsonDecode(await file.readAsString()) as List<dynamic>)
          User.fromJson(u as Map<String, dynamic>),
      ];
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
