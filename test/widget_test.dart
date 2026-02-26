import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clg_admin/main.dart';

void main() {
  testWidgets('shows splash then login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const CanteenAdminApp());

    expect(find.text('College Canteen'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('Admin Login'), findsOneWidget);
  });
}
