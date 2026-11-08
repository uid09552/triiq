import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:triiq/app.dart';

void main() {
  testWidgets('App shell shows Today by default and can switch tabs', (
    WidgetTester tester,
  ) async {
    // Past the first-run flow (covered in onboarding_test.dart).
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    await tester.pumpWidget(const TriiqApp());

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Ready to train'), findsOneWidget);

    // Not pumpAndSettle: Today's data-loading spinner is indeterminate and
    // stays mounted (offstage) in the IndexedStack, so it never settles.
    await tester.tap(find.text('Insights'));
    await tester.pump();

    // The Insights hub lists every analysis view, whatever data exists.
    expect(find.text('Performance curves'), findsWidgets);
    expect(find.text('Metric explorer'), findsWidgets);
  });
}
