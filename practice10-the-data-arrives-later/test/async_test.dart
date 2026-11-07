import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:students_async/main.dart';

void main() {
  final log = <String>[];
  // The binding checks debugPrint is restored before tearDown runs.
  void testWidgets(String name, WidgetTesterCallback body) =>
      flutter_test.testWidgets(name, (t) async {
        log.clear();
        final original = debugPrint;
        debugPrint = (m, {wrapWidth}) => log.add(m!);
        try {
          await body(t);
        } finally {
          debugPrint = original;
        }
      });

  Future<void> open(WidgetTester t, String button) async {
    await t.pumpWidget(const App());
    await t.tap(find.text(button));
    await t.pump();
    await t.pump(const Duration(milliseconds: 500)); // route animation
  }

  Future<void> refresh(WidgetTester t) async {
    await t.tap(find.byTooltip('Refresh'));
    await t.pump();
    await t.pump(const Duration(seconds: 2));
  }

  testWidgets('by hand: data, error on the 3rd call, retry', (t) async {
    await open(t, 'By hand');
    expect(find.text('Loading students…'), findsOneWidget);
    await t.pump(const Duration(seconds: 2));
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    expect(find.text('—'), findsOneWidget); // Aruzhan has no gpa

    await refresh(t);
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    await refresh(t);
    expect(find.text('Could not load students'), findsOneWidget);

    await t.tap(find.text('Retry'));
    await t.pump();
    expect(find.text('Loading students…'), findsOneWidget);
    await t.pump(const Duration(seconds: 2));
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    expect(log, [for (var i = 1; i <= 4; i++) 'fetchStudents #$i']);
  });

  testWidgets('by hand: leaving mid-load is clean', (t) async {
    await open(t, 'By hand');
    await t.pageBack();
    await t.pumpAndSettle();
    await t.pump(const Duration(seconds: 3));
    expect(t.takeException(), isNull);
  });

  testWidgets('FutureBuilder: the Switch never refetches', (t) async {
    await open(t, 'FutureBuilder');
    await t.pump(const Duration(seconds: 2));
    expect(find.text('Dana Omarova'), findsOneWidget);
    for (var i = 0; i < 10; i++) {
      await t.tap(find.byType(Switch));
      await t.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    }
    expect(log, ['fetchStudents #1']);

    await refresh(t);
    await refresh(t);
    expect(find.text('Could not load students'), findsOneWidget);
    await t.tap(find.text('Retry'));
    await t.pump(const Duration(seconds: 2));
    await t.pump();
    expect(find.text('Dana Omarova'), findsOneWidget);
  });

  testWidgets('save: pop on success, snackbar on failure', (t) async {
    await open(t, 'By hand');
    await t.pump(const Duration(seconds: 2));
    await t.pumpAndSettle(); // FAB entrance animation
    await t.tap(find.byTooltip('Save'));
    await t.pump();
    await t.tap(find.byTooltip('Save')); // disabled: no second request
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
    expect(find.text('Countdown'), findsOneWidget, reason: 'popped home');

    await t.tap(find.text('By hand'));
    await t.pumpAndSettle();
    await t.pump(const Duration(seconds: 2));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Save'));
    await t.pump(const Duration(seconds: 1));
    await t.pump();
    expect(find.text('server rejected 6'), findsOneWidget);
    expect(find.text('Countdown'), findsNothing, reason: 'stayed on screen');
  });

  testWidgets('countdown A and B: leaving at 7 stops the ticks', (t) async {
    for (final version in ['A: StreamBuilder', 'B: listen']) {
      log.clear();
      await open(t, 'Countdown');
      await t.tap(find.text(version));
      await t.pump();
      // The first value (10) arrives after one second, 7 after four.
      for (var i = 0; i < 4; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      expect(find.text('7'), findsOneWidget, reason: version);
      await t.pageBack();
      await t.pumpAndSettle();
      final ticks = log.where((l) => l.startsWith('tick')).length;
      await t.pump(const Duration(seconds: 10));
      expect(log.where((l) => l.startsWith('tick')).length, ticks);
      expect(t.takeException(), isNull);
    }
  });
}
