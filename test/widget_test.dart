import 'package:flutter_test/flutter_test.dart';

import 'package:omnirouteapp/main.dart';

void main() {
  testWidgets('App builds and shows the Antigravity title', (WidgetTester tester) async {
    await tester.pumpWidget(const AntigravityApp());
    expect(find.text('Antigravity'), findsWidgets);
  });
}
