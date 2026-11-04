import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/pending_writes.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/widgets/pending_changes_card.dart';

class _Service extends PendingWritesService {
  _Service() : super();

  int flushes = 0;
  int retries = 0;

  void set(int p, int f) {
    pending = p;
    failed = f;
    notifyListeners();
  }

  @override
  Future<int> flush() async {
    flushes++;
    return 0;
  }

  @override
  Future<void> retryFailed() async => retries++;
}

void main() {
  Widget wrap(Widget w) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: w),
  );

  testWidgets('hidden when empty, shows and reacts when changes wait', (t) async {
    final s = _Service();
    await t.pumpWidget(wrap(PendingChangesCard(service: s)));
    expect(find.byKey(const ValueKey('pending-card')), findsNothing);

    s.set(2, 0);
    await t.pumpAndSettle();
    expect(find.text('2 changes waiting to sync'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('pending-send')));
    expect(s.flushes, 1);

    s.set(0, 1);
    await t.pumpAndSettle();
    expect(find.text('1 change could not be sent'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('pending-retry')));
    expect(s.retries, 1);
  });
}
