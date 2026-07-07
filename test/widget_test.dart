import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/main.dart';

void main() {
  testWidgets('App renders welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SonusApp());
    await tester.pumpAndSettle();

    expect(find.text('Sonus Music'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
