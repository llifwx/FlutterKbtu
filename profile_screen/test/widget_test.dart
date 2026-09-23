import 'package:flutter_test/flutter_test.dart';
import 'package:profile_screen/main.dart';

void main() {
  testWidgets('shows the profile screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('My profile'), findsOneWidget);
    expect(find.text('YOUR NAME'), findsOneWidget);
    expect(find.text('Kazakh-British Technical University'), findsOneWidget);
    expect(find.text('Flutter I'), findsOneWidget);
  });
}
