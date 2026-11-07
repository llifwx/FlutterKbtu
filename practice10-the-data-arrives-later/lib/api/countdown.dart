import 'package:flutter/foundation.dart';

Stream<int> countdown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
    debugPrint('tick $i');
  }
}
