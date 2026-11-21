import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/widgets/hold_tip.dart';

void main() {
  Widget app(HoldTipStore store) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: HoldTipCard(store: store)),
  );

  testWidgets('shows once, until dismissed, and stays gone', (t) async {
    SharedPreferences.setMockInitialValues({});
    final store = HoldTipStore.forTesting();
    await t.pumpWidget(app(store));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('hold-tip')), findsOneWidget);
    expect(find.textContaining('hold a tile'), findsOneWidget);

    await t.tap(find.byKey(const ValueKey('hold-tip-dismiss')));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('hold-tip')), findsNothing);

    // A new run: the choice was remembered.
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(app(HoldTipStore.forTesting()));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('hold-tip')), findsNothing);
  });
}
