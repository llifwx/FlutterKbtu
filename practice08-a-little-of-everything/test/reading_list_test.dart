import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_list/main.dart';
import 'package:reading_list/models/book.dart';
import 'package:reading_list/widgets/book_tile.dart';

void main() {
  test(
    'plain Dart model handles nullable fields and ordered unique authors',
    () {
      final book = Book.fromMap({'title': 'X', 'author': 'Y', 'pages': 10});
      expect(book.year, isNull);
      expect(book.read, isFalse);
      expect(book.toString(), 'X — Y, 10 pp.');
      expect(
        seed[1].toString(),
        'Null Safety for Humans — B. Seitkali, 196 pp. (2022)',
      );
      expect(totalPages(seed), 1220);
      expect(unread(seed), hasLength(4));
      expect(authors([book, seed[1], book]), ['Y', 'B. Seitkali']);
      expect(totalPages([]), 0);
    },
  );

  testWidgets('filters update immediately and leave the seed unchanged', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.widgetWithText(ChoiceChip, 'Unread'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (4)'), findsOneWidget);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(find.text('Reading list (3)'), findsOneWidget);
    expect(find.text('Null Safety for Humans'), findsNothing);
    expect(seed[1].read, isFalse);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Read'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (2)'), findsOneWidget);
    expect(find.text('Null Safety for Humans'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (5)'), findsOneWidget);
  });

  testWidgets('detail returns actions and delete requires confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Constraints Go Down, Sizes Go Up'));
    await tester.pumpAndSettle();
    expect(find.text('Year unknown'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Reading list (5)'), findsOneWidget);
    await tester.tap(find.text('Constraints Go Down, Sizes Go Up'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark as read'));
    await tester.pumpAndSettle();
    final tile = tester.widget<BookTile>(find.byType(BookTile).at(2));
    expect(tile.book.read, isTrue);
    await tester.tap(find.text('Constraints Go Down, Sizes Go Up'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Book details'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (4)'), findsOneWidget);
    expect(find.text('Constraints Go Down, Sizes Go Up'), findsNothing);
  });

  testWidgets(
    'form validates numbers, accepts a null year, and cancels safely',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter at least 2 characters'), findsOneWidget);
      expect(find.text('Enter an author'), findsOneWidget);
      expect(find.text('A whole number above 0'), findsOneWidget);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), ' New Book ');
      await tester.enterText(fields.at(1), ' New Author ');
      for (final invalid in ['abc', '0', '-2', '1.5']) {
        await tester.enterText(fields.at(2), invalid);
        await tester.pumpAndSettle();
        expect(find.text('A whole number above 0'), findsOneWidget);
      }
      await tester.enterText(fields.at(2), '80');
      for (final invalid in ['abc', '1449', '${DateTime.now().year + 1}']) {
        await tester.enterText(fields.at(3), invalid);
        await tester.pumpAndSettle();
        expect(
          find.text('Enter a year from 1450 to ${DateTime.now().year}'),
          findsOneWidget,
        );
      }
      await tester.enterText(fields.at(3), '');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Reading list (6)'), findsOneWidget);
      expect(find.text('1300'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('New Book'),
        200,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(find.text('New Book'));
      await tester.pumpAndSettle();
      expect(find.text('New Author'), findsOneWidget);
      expect(find.text('Year unknown'), findsOneWidget);
      expect(find.text('Status: Unread'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Reading list (6)'), findsOneWidget);
    },
  );

  testWidgets('portrait, landscape, large text and keyboard avoid overflow', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    for (final size in [const Size(320, 640), const Size(740, 320)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Unread'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(seed.last.title),
        120,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      expect(tester.takeException(), isNull);
      final title = tester.widget<Text>(find.text(seed.last.title));
      expect(title.maxLines, 2);
      expect(title.overflow, TextOverflow.ellipsis);
      await tester.pumpWidget(const SizedBox());
    }
    tester.view.physicalSize = const Size(320, 640);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.5)),
          child: child ?? const SizedBox(),
        ),
        home: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an author'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
