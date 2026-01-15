import 'package:flutter_test/flutter_test.dart';
import 'package:gym_master/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GymMasterApp());

    // Verify that the app loads
    expect(find.text('GYMMASTER'), findsOneWidget);
  });
}
