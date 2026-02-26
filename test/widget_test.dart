import 'package:flutter_test/flutter_test.dart';

import 'package:clg_admin/main.dart';

void main() {
  testWidgets('shows splash then login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CanteenAdminApp());

    expect(find.text('College Canteen'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Admin Login'), findsOneWidget);
  });
}
