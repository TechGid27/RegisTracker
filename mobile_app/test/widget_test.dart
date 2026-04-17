import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RegisTrackApp());

    // Verify that the login screen is showing (it should have 'Login' or similar)
    // Adjust based on your login screen's default text.
    expect(find.textContaining('Login'), findsWidgets);
  });
}
