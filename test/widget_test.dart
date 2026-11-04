import 'package:flutter_test/flutter_test.dart';

import 'package:triiq/app.dart';

void main() {
  testWidgets('App shell shows Today by default and can switch tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TriiqApp());

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Ready to train'), findsOneWidget);

    // Not pumpAndSettle: Today's data-loading spinner is indeterminate and
    // stays mounted (offstage) in the IndexedStack, so it never settles.
    await tester.tap(find.text('Statistics'));
    await tester.pump();

    // Statistics shows the Performance entry at the top, whatever data exists.
    expect(find.text('Performance'), findsWidgets);
  });
}
