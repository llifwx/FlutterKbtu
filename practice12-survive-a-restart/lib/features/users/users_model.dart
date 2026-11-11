import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;
  bool fromCache = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final r = await _repo.getAll();
      items = r.items;
      fromCache = r.fromCache;
    } on ApiException catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Puts the server's copy (with its id) on top. Errors go to the caller:
  /// the form stays open and shows them.
  Future<User> create(User draft) async {
    final created = await _repo.create(draft);
    items = [created, ...items];
    notifyListeners();
    return created;
  }
}
