import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/memory/memory_screen.dart';

void main() {
  testWidgets('the Trainer memory screen warns to use it with care', (t) async {
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const MemoryScreen(),
      ),
    );
    await t.pump();
    expect(find.byKey(const ValueKey('memory-care-note')), findsOneWidget);
    expect(find.textContaining('overtraining'), findsOneWidget);
    expect(find.textContaining('cannot guarantee'), findsOneWidget);
  });
}
