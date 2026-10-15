import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_screen/main.dart';

void main() {
  testWidgets('shows practice 4 screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('A screen that reacts'), findsOneWidget);
    expect(find.text('Tap this card'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
  });
}
