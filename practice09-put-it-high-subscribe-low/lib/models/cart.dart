import 'package:flutter/foundation.dart';

import 'book.dart';

class Cart extends ChangeNotifier {
  final Map<Book, int> _qty = {};

  List<Book> get items => List.unmodifiable(_qty.keys);
  int get count => _qty.length;
  int get total =>
      _qty.entries.fold(0, (sum, e) => sum + e.key.price * e.value);

  int qtyOf(Book b) => _qty[b] ?? 0;

  bool add(Book b) {
    if (_qty.containsKey(b)) return false;
    _qty[b] = 1;
    notifyListeners();
    return true;
  }

  void increment(Book b) {
    _qty[b] = qtyOf(b) + 1;
    notifyListeners();
  }

  void remove(Book b) {
    _qty.remove(b);
    notifyListeners();
  }

  void clear() {
    _qty.clear();
    notifyListeners();
  }
}
