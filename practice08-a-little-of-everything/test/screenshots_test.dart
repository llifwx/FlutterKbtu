import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_list/main.dart';

// Run with --update-goldens to regenerate the submission previews.
void main() {
  testWidgets('capture unread list and empty-form errors', (tester) async {
    final sdk = Platform.environment['FLUTTER_ROOT'];
    if (sdk == null) throw StateError('Run this test using flutter test.');
    await tester.runAsync(() async {
      final fonts = FontLoader('Roboto');
      for (final name in ['regular', 'medium', 'bold']) {
        fonts.addFont(
          File('$sdk/bin/cache/artifacts/material_fonts/roboto-$name.ttf')
              .readAsBytes()
              .then((bytes) => ByteData.sublistView(bytes)),
        );
      }
      await fonts.load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const RepaintBoundary(key: ValueKey('capture'), child: MyApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Unread'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('capture')),
      matchesGoldenFile('../screenshot_list.png'),
    );
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('capture')),
      matchesGoldenFile('../screenshot_form.png'),
    );
    expect(tester.takeException(), isNull);
  }, tags: ['screenshots']);
}
