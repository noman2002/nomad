import 'package:flutter_test/flutter_test.dart';

import 'package:nomad/main.dart';

void main() {
  testWidgets('App boots into onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(enableAuthGate: false));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Welcome to Nomad'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
