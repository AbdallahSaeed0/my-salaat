import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prayer_reminder/main.dart';

void main() {
  testWidgets('App boots and shows the home app bar', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PrayerReminderApp()));
    await tester.pump();

    expect(find.text('My Salaat'), findsOneWidget);
  });
}
