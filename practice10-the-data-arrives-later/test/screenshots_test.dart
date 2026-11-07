import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:students_async/main.dart';

Future<ByteData> _windowsFont(String file) async =>
    ByteData.sublistView(await File('C:/Windows/Fonts/$file').readAsBytes());

// Run with --update-goldens to regenerate the submission screenshots.
void main() {
  testWidgets('capture error view and countdown B', (t) async {
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
    const capture = ValueKey('capture');
    await t.pumpWidget(const RepaintBoundary(key: capture, child: App()));

    await t.tap(find.text('By hand'));
    await t.pumpAndSettle();
    await t.pump(const Duration(seconds: 2));
    for (var i = 0; i < 2; i++) {
      await t.tap(find.byTooltip('Refresh'));
      await t.pump(const Duration(seconds: 2));
    }
    await t.pumpAndSettle(); // let the Save button finish leaving
    await expectLater(
      find.byKey(capture),
      matchesGoldenFile('../screenshot_error.png'),
    );

    await t.pageBack();
    await t.pumpAndSettle();
    await t.tap(find.text('Countdown'));
    await t.pumpAndSettle();
    await t.tap(find.text('B: listen'));
    await t.pump();
    for (var i = 0; i < 4; i++) {
      await t.pump(const Duration(seconds: 1));
    }
    await expectLater(
      find.byKey(capture),
      matchesGoldenFile('../screenshot_countdown.png'),
    );
    await t.pageBack();
    await t.pumpAndSettle();
    await t.pump(const Duration(seconds: 10));
    debugDefaultTargetPlatformOverride = null;
  }, skip: !Platform.isWindows);
}
