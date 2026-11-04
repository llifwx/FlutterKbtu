import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop/main.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

void main() {
  test('Cart: no duplicates, quantities, unmodifiable items, notifies', () {
    var notified = 0;
    final cart = Cart()..addListener(() => notified++);
    expect(cart.add(books[0]), isTrue);
    expect(cart.add(books[0]), isFalse);
    expect(notified, 1);
    cart.increment(books[0]);
    cart.add(books[1]);
    expect(cart.count, 2);
    expect(cart.qtyOf(books[0]), 2);
    expect(cart.total, 4200 * 2 + 3100);
    expect(() => cart.items.add(books[2]), throwsUnsupportedError);
    cart.remove(books[0]);
    expect(cart.qtyOf(books[0]), 0);
    cart.clear();
    expect(cart.count, 0);
    expect(notified, 5);
  });

  group('app', () {
    late List<String> log;
    late DebugPrintCallback original;
    late Cart cart;

    Future<void> start(WidgetTester t) async {
      t.view.physicalSize = const Size(1200, 1600);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      cart = Cart();
      log = [];
      original = debugPrint;
      debugPrint = (m, {wrapWidth}) => log.add(m ?? '');
      await t.pumpWidget(
        ChangeNotifierProvider.value(value: cart, child: const Shell()),
      );
      await t.pumpAndSettle();
    }

    int lines(List<String> l, String prefix) =>
        l.where((x) => x.startsWith(prefix)).length;

    testWidgets('both routes share the cart', (t) async {
      await start(t);
      await t.tap(find.text('Add').first);
      await t.pumpAndSettle();
      await t.tap(find.text('Add').first);
      await t.pumpAndSettle();
      expect(cart.count, 2);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Add'), findsNWidgets(4));
      await t.tap(find.byTooltip('Cart'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('More').first);
      await t.pumpAndSettle();
      expect(find.text('×2'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Row),
          matching: find.text('${4200 * 2 + 3100} ₸'),
        ),
        findsWidgets,
      );
      await t.tap(find.byTooltip('Remove').first);
      await t.pumpAndSettle();
      await t.pageBack();
      await t.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Add'), findsNWidgets(5));
      debugPrint = original;
    });

    testWidgets('rebuild counts stay low', (t) async {
      await start(t);
      log.clear();
      await t.tap(find.text('Add').first);
      await t.pump();
      final add = List.of(log);
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Cart'));
      await t.pumpAndSettle();
      final labelBuilds = lines(log, 'total label');
      log.clear();
      for (var i = 0; i < 3; i++) {
        await t.tap(find.byTooltip('More'));
        await t.pump();
      }
      final plus = List.of(log);
      log.clear();
      await t.tap(find.byTooltip('Remove'));
      await t.pump();
      final removed = List.of(log);
      await t.pumpAndSettle();
      debugPrint = original;
      debugPrint(
        'MEASURE add=${add.length} $add\n'
        'MEASURE plus badge=${lines(plus, 'badge')} rows=${lines(plus, 'row')} '
        'screen=${lines(plus, 'BooksScreen')} label=${lines(plus, 'total')}\n'
        'MEASURE remove badge=${lines(removed, 'badge')} '
        'rows=${lines(removed, 'row')} screen=${lines(removed, 'BooksScreen')}',
      );
      expect(labelBuilds, 1);
      expect(lines(add, 'BooksScreen'), 0);
      expect(lines(add, 'row'), 1);
      expect(lines(add, 'badge'), 1);
      expect(plus, isEmpty);
      expect(lines(removed, 'badge'), 1);
    });

    testWidgets('search filters by title; snackbar only on true', (t) async {
      await start(t);
      await t.enterText(find.byType(TextField), 'navigator');
      await t.pump();
      expect(find.byType(ListTile), findsOneWidget);
      final button = t.widget<OutlinedButton>(find.byType(OutlinedButton));
      button.onPressed!();
      await t.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      await t.pumpAndSettle();
      await t.pump(const Duration(seconds: 5));
      await t.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      button.onPressed!(); // stale handler: a second tap on the same book
      await t.pump();
      expect(find.byType(SnackBar), findsNothing);
      expect(cart.qtyOf(books[3]), 1);
      debugPrint = original;
    });

    testWidgets('clear asks first', (t) async {
      await start(t);
      await t.tap(find.text('Add').first);
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Cart'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Clear cart'));
      await t.pumpAndSettle();
      await t.tap(find.text('Cancel'));
      await t.pumpAndSettle();
      expect(cart.count, 1);
      await t.tap(find.byTooltip('Clear cart'));
      await t.pumpAndSettle();
      await t.tap(find.text('Clear'));
      await t.pumpAndSettle();
      expect(cart.count, 0);
      debugPrint = original;
    });
  });
}
