import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signup_form/main.dart';
import 'package:signup_form/summary_card.dart';

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> reveal(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

Future<void> agree(WidgetTester tester) async {
  await reveal(tester, find.byType(CheckboxListTile));
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pumpAndSettle();
}

Future<void> fillValidForm(WidgetTester tester) async {
  await tester.enterText(field('Name'), 'Amina');
  await tester.enterText(field('Email'), 'amina@kbtu.kz');
  await tester.enterText(field('Password'), 'student123');
  await tester.enterText(field('Confirm password'), 'student123');
  await reveal(tester, find.byType(DropdownButtonFormField<String>));
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('IT-2302').last);
  await tester.pumpAndSettle();
  await reveal(tester, field('Date of birth'));
  await tester.tap(field('Date of birth'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  await agree(tester);
}

void main() {
  testWidgets(
    'disabled consent gate and all field errors, then live correction',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('Name is too short'), findsNothing);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await agree(tester);
      await reveal(tester, find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      for (final error in [
        'Name is too short',
        'Email looks wrong',
        'Password is too short',
        'Confirm your password',
        'Choose a group',
        'Choose your date of birth',
      ]) {
        expect(find.text(error), findsOneWidget);
      }
      await tester.enterText(field('Name'), '  Amina  ');
      await tester.enterText(field('Email'), 'amina@kbtu.kz');
      await tester.enterText(field('Password'), 'student123');
      await tester.enterText(field('Confirm password'), 'student123');
      await tester.pumpAndSettle();
      expect(find.text('Name is too short'), findsNothing);
      expect(find.text('Email looks wrong'), findsNothing);
      expect(find.text('Confirm your password'), findsNothing);
      await tester.enterText(field('Password'), 'different123');
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(find.text('12 of 8'), findsOneWidget);
      expect(
        tester.widget<TextFormField>(field('Name')).controller?.text,
        '  Amina  ',
      );
    },
  );

  testWidgets(
    'date cancellation preserves selection, submit and reset clear everything',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await fillValidForm(tester);
      await reveal(tester, field('Date of birth'));
      final dateBefore = tester
          .widget<TextFormField>(field('Date of birth'))
          .controller
          ?.text;
      expect(dateBefore, '01.01.2005');
      await tester.tap(field('Date of birth'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextFormField>(field('Date of birth')).controller?.text,
        dateBefore,
      );
      await reveal(tester, find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.byType(Form), findsNothing);
      expect(find.byType(SummaryCard), findsOneWidget);
      expect(find.text('Amina'), findsOneWidget);
      expect(find.text('IT-2302'), findsOneWidget);
      expect(find.text('Account created'), findsOneWidget);
      await tester.tap(find.text('Start over'));
      await tester.pumpAndSettle();
      for (final label in [
        'Name',
        'Email',
        'Password',
        'Confirm password',
        'Date of birth',
      ]) {
        expect(
          tester.widget<TextFormField>(field(label)).controller?.text,
          isEmpty,
        );
      }
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(find.text('0 of 8'), findsOneWidget);
      expect(find.text('Name is too short'), findsNothing);
      await agree(tester);
      await reveal(tester, find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Choose a group'), findsOneWidget);
      expect(find.text('Choose your date of birth'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('keyboard next chain and done respect consent and submit', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await fillValidForm(tester);
    await reveal(tester, field('Name'));
    await tester.tap(field('Name'));
    await tester.pumpAndSettle();
    for (final label in ['Email', 'Password', 'Confirm password']) {
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      final editable = tester.widget<EditableText>(
        find.descendant(of: field(label), matching: find.byType(EditableText)),
      );
      expect(editable.focusNode.hasFocus, isTrue);
    }
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(SummaryCard), findsOneWidget);
  });

  testWidgets(
    'keyboard inset leaves confirm and button scrollable without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(const MyApp());
      await reveal(tester, field('Confirm password'));
      await tester.tap(field('Confirm password'));
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      await tester.pumpAndSettle();
      await reveal(tester, field('Confirm password'));
      expect(
        tester.getBottomRight(field('Confirm password')).dy,
        lessThanOrEqualTo(524),
      );
      await reveal(tester, find.byType(FilledButton));
      expect(
        tester.getBottomRight(find.byType(FilledButton)).dy,
        lessThanOrEqualTo(524),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('summary uses its own box at the 600px breakpoint', (
    tester,
  ) async {
    for (final width in [639.0, 640.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: const SummaryCard(
                  name: 'Amina',
                  email: 'amina@kbtu.kz',
                  group: 'IT-2302',
                  birthDate: '01.01.2005',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(GridView),
        width < 640 ? findsNothing : findsOneWidget,
      );
      expect(find.byType(ListTile), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    }
  });
}
