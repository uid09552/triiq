import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/app.dart';
import 'package:triiq/widgets/main_navigation.dart';

void main() {
  setUp(() {
    // Past the first-run flow (covered in onboarding_test.dart).
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    MainNavigation.instance.debugReset();
  });

  testWidgets('openCalendar selects the Calendar tab and shows the date', (
    tester,
  ) async {
    await tester.pumpWidget(const TriiqApp());
    await tester.pump();

    NavigationBar bar() => tester.widget(find.byType(NavigationBar));
    expect(bar().selectedIndex, MainNavigation.todayTab);

    MainNavigation.instance.openCalendar(DateTime(2027, 3, 10, 15));
    await tester.pump();
    await tester.pump();

    expect(bar().selectedIndex, MainNavigation.calendarTab);
    // The breadcrumb: 2027 › March.
    expect(find.text('2027'), findsOneWidget);
    expect(find.text('March'), findsOneWidget);
    expect(MainNavigation.instance.calendarFocus!.date, DateTime(2027, 3, 10));
  });
}
