import 'package:flutter_test/flutter_test.dart';
import 'package:practice06/main.dart';
import 'package:practice06/students_screen.dart';

void main() {
  testWidgets('App opens the students screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.byType(StudentsScreen), findsOneWidget);
    expect(find.text('Students'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
