import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/evaluation/fatigue_warning.dart';
import 'package:triiq/evaluation/fatigue_warning_service.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/today/fatigue_warning_card.dart';

class _Service implements FatigueWarningService {
  _Service(this.level);

  FatigueLevel level;

  @override
  Future<FatigueWarning> load() async => FatigueWarning(
    level: level,
    window: 5,
    signals: level == FatigueLevel.none
        ? const []
        : const [
            FatigueSignal(
              kind: FatigueSignalKind.hrvLow,
              badDays: 4,
              dataDays: 5,
              fires: true,
            ),
            FatigueSignal(
              kind: FatigueSignalKind.sleepShort,
              badDays: 3,
              dataDays: 5,
              fires: true,
            ),
          ],
  );

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Ping extends ChangeNotifier {
  void ping() => notifyListeners();
}

void main() {
  Widget wrap(Widget w) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: w),
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('nothing for level none', (t) async {
    await t.pumpWidget(
      wrap(
        FatigueWarningBanner(
          service: _Service(FatigueLevel.none),
          sync: _Ping(),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('fatigue-card')), findsNothing);
  });

  testWidgets('watch lists the reasons; dismissing hides it for the day', (
    t,
  ) async {
    final clock = DateTime(2026, 5, 20, 8);
    final sync = _Ping();
    final service = _Service(FatigueLevel.watch);
    await t.pumpWidget(
      wrap(
        FatigueWarningBanner(service: service, sync: sync, clock: () => clock),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('Fatigue is building'), findsOneWidget);
    expect(
      find.textContaining('HRV below your normal on 4 of the last 5 days'),
      findsOneWidget,
    );

    await t.tap(find.byKey(const ValueKey('fatigue-dismiss')));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('fatigue-card')), findsNothing);

    // Same level after the next sync: stays hidden. A worse level returns.
    sync.ping();
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('fatigue-card')), findsNothing);
    service.level = FatigueLevel.warning;
    sync.ping();
    await t.pumpAndSettle();
    expect(find.text('Fatigue warning'), findsOneWidget);
  });
}
