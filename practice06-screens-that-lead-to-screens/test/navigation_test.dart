import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice06/detail_screen.dart';
import 'package:practice06/edit_screen.dart';
import 'package:practice06/main.dart';
import 'package:practice06/students.dart';

Future<void> openDetail(WidgetTester tester) async {
  await tester.pumpWidget(const MainApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text(students.first.name));
  await tester.pumpAndSettle();
}

Future<void> openEdit(WidgetTester tester) async {
  await openDetail(tester);
  await tester.tap(find.byTooltip('Edit student'));
  await tester.pumpAndSettle();
}

Future<void> appBarBack(WidgetTester tester) async {
  await tester.pump();
  await tester.tap(find.byTooltip('Back'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('all eight rows show the required data and root has no Back', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.text('Students'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(8));
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(8));
    expect(find.byTooltip('Back'), findsNothing);
    for (final student in students) {
      final tile = find.ancestor(
        of: find.text(student.name),
        matching: find.byType(ListTile),
      );
      expect(
        find.descendant(of: tile, matching: find.text(student.group)),
        findsOneWidget,
      );
      final avatar = find.descendant(
        of: tile,
        matching: find.byType(CircleAvatar),
      );
      expect(
        find.descendant(of: avatar, matching: find.text(student.name[0])),
        findsOneWidget,
      );
    }
  });

  testWidgets('detail has student data, automatic Back, and returns to list', (
    tester,
  ) async {
    await openDetail(tester);
    expect(find.byType(DetailScreen), findsOneWidget);
    expect(find.text('Aida Akhmetova'), findsOneWidget);
    expect(find.text('IT-2302'), findsOneWidget);
    expect(find.text('aida@kbtu.kz'), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
    expect(find.byIcon(Icons.mail), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    await appBarBack(tester);
    expect(find.text('Students'), findsOneWidget);
  });

  testWidgets(
    'returning from detail preserves scroll position and original list',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      final offset = position.pixels;
      expect(offset, greaterThan(0));
      await tester.tap(find.text('Yerlan Sadyk'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit student'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Yerlan Updated');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await appBarBack(tester);
      expect(position.pixels, offset);
      expect(find.text('Yerlan Sadyk'), findsOneWidget);
      expect(find.text('Yerlan Updated'), findsNothing);
    },
  );

  testWidgets(
    'Save returns edited name, preserves other fields, and skips dialog',
    (tester) async {
      await openEdit(tester);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller,
        isNull,
      );
      expect(find.byType(EditableText), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        isEmpty,
      );
      await tester.enterText(find.byType(TextField), 'Aida Updated');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.byType(EditScreen), findsNothing);
      expect(find.text('Aida Updated'), findsOneWidget);
      expect(find.text('IT-2302'), findsOneWidget);
      expect(find.text('aida@kbtu.kz'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      await tester.tap(find.byTooltip('Edit student'));
      await tester.pumpAndSettle();
      expect(find.text('Current name: Aida Updated'), findsOneWidget);
    },
  );

  testWidgets('unchanged empty input cancels immediately', (tester) async {
    await openEdit(tester);
    await appBarBack(tester);
    expect(find.byType(EditScreen), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Aida Akhmetova'), findsOneWidget);
  });

  testWidgets('Save without typing returns the existing name', (tester) async {
    await openEdit(tester);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Aida Akhmetova'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'Keep editing preserves draft and Discard preserves original name',
    (tester) async {
      await openEdit(tester);
      await tester.enterText(find.byType(TextField), 'Unsaved name');
      await appBarBack(tester);
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.byType(EditScreen), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'Unsaved name',
      );
      await appBarBack(tester);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.byType(EditScreen), findsNothing);
      expect(find.text('Aida Akhmetova'), findsOneWidget);
      expect(find.text('Unsaved name'), findsNothing);
    },
  );

  testWidgets(
    'system Back prompts and repeated attempts open only one dialog',
    (tester) async {
      await openEdit(tester);
      await tester.enterText(find.byType(TextField), 'Unsaved name');
      final navigator = Navigator.of(tester.element(find.byType(TextField)));
      await tester.pump();
      await tester.binding.handlePopRoute();
      // Exercise another attempt on the edit route while its dialog is pending.
      final editContext = tester.element(find.byType(TextField));
      final scope = tester.widget<PopScope<String>>(
        find.descendant(
          of: find.byType(EditScreen),
          matching: find.byType(PopScope<String>),
        ),
      );
      scope.onPopInvokedWithResult?.call(false, null);
      expect(Navigator.of(editContext), navigator);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.byType(EditScreen), findsNothing);
      expect(find.text('Aida Akhmetova'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('restoring the original name clears dirty state dynamically', (
    tester,
  ) async {
    await openEdit(tester);
    await tester.enterText(find.byType(TextField), 'Different name');
    await tester.enterText(find.byType(TextField), 'Aida Akhmetova');
    await appBarBack(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(EditScreen), findsNothing);
  });
}
