import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop/main.dart';
import 'package:shop/models/cart.dart';

Future<ByteData> _windowsFont(String file) async =>
    ByteData.sublistView(await File('C:/Windows/Fonts/$file').readAsBytes());

// Run with --update-goldens to regenerate the submission previews.
// Renders with the Windows typography: Roboto has no tenge sign.
void main() {
  testWidgets('capture books and cart', (t) async {
    await t.runAsync(() async {
      await (FontLoader('Segoe UI')
            ..addFont(_windowsFont('segoeui.ttf'))
            ..addFont(_windowsFont('segoeuib.ttf')))
          .load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = const Size(390, 844);
    addTearDown(t.view.reset);
    await t.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('capture'),
        child: ChangeNotifierProvider(
          create: (_) => Cart(),
          child: const Shell(),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('Add').first);
    await t.pumpAndSettle();
    await t.tap(find.text('Add').first);
    await t.pumpAndSettle();
    await t.pump(const Duration(seconds: 5));
    await t.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('capture')),
      matchesGoldenFile('../screenshot_books.png'),
    );
    await t.tap(find.byTooltip('Cart'));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('More').first);
    await t.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('capture')),
      matchesGoldenFile('../screenshot_cart.png'),
    );
    debugDefaultTargetPlatformOverride = null;
  }, skip: !Platform.isWindows);
}
