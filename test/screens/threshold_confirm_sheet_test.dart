import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/intervals_session.dart';
import 'package:triiq/data/sport_settings_service.dart';
import 'package:triiq/evaluation/performance_curves.dart';
import 'package:triiq/evaluation/threshold_suggestions.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/statistics/threshold_confirm_sheet.dart';

class _FakeSportSettingsService implements SportSettingsService {
  _FakeSportSettingsService({this.applyError, this.undoError});

  final Object? applyError;
  final Object? undoError;
  final applyCalls = <(ThresholdSuggestion, bool)>[];
  final undoCalls = <ThresholdSuggestion>[];

  @override
  Future<SportSettings> apply(
    ThresholdSuggestion suggestion, {
    bool recalcHrZones = false,
  }) async {
    applyCalls.add((suggestion, recalcHrZones));
    if (applyError != null) throw applyError!;
    return SportSettings(id: 1, ftp: suggestion.candidateValue.round());
  }

  @override
  Future<SportSettings> undo(ThresholdSuggestion suggestion) async {
    undoCalls.add(suggestion);
    if (undoError != null) throw undoError!;
    return SportSettings(id: 1, ftp: suggestion.currentValue.round());
  }
}

const _suggestion = ThresholdSuggestion(
  sport: CurveSport.ride,
  field: 'ftp',
  currentValue: 252,
  candidateValue: 262,
  direction: ThresholdDirection.up,
  basisKind: ThresholdBasisKind.rideSeasonModel,
);

void main() {
  IntervalsSession session() {
    final s = IntervalsSession.forTesting(connected: true, athleteId: 'a1');
    s.athlete = WithSportSettings(
      sportSettings: [
        SportSettings(
          id: 1,
          types: const [SportSettingsTypesEnum.ride],
          ftp: 252,
          powerZones: const [55, 75, 90, 105, 120],
          powerZoneNames: const ['Z1', 'Z2', 'Z3', 'Z4', 'Z5'],
        ),
      ],
    );
    return s;
  }

  Future<_Result> openSheet(
    WidgetTester tester, {
    required _FakeSportSettingsService service,
  }) async {
    final result = _Result();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result.value = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => ThresholdConfirmSheet(
                    suggestion: _suggestion,
                    service: service,
                    session: session(),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('shows current and new value, and the zone table', (tester) async {
    final service = _FakeSportSettingsService();
    await openSheet(tester, service: service);

    expect(find.text('252 W'), findsOneWidget);
    expect(find.text('262 W'), findsOneWidget);
    expect(find.text('Zone ranges'), findsOneWidget);
    expect(find.text('Z1'), findsOneWidget);
  });

  testWidgets('applying calls the service and shows success', (tester) async {
    final service = _FakeSportSettingsService();
    await openSheet(tester, service: service);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(service.applyCalls, hasLength(1));
    expect(service.applyCalls.single.$1.candidateValue, 262);
    expect(service.applyCalls.single.$2, isFalse);
    expect(find.text('Updated'), findsOneWidget);
  });

  testWidgets('the HR-zones opt-in is passed through to apply', (tester) async {
    final service = _FakeSportSettingsService();
    await openSheet(tester, service: service);

    await tester.tap(find.text('Also recalculate HR zones'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(service.applyCalls.single.$2, isTrue);
  });

  testWidgets('a failed apply shows the error and keeps the sheet open',
      (tester) async {
    final service = _FakeSportSettingsService(applyError: StateError('boom'));
    await openSheet(tester, service: service);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.textContaining("Couldn't update"), findsOneWidget);
    expect(find.text('Updated'), findsNothing);
  });

  testWidgets('undo after a successful apply calls the service', (tester) async {
    final service = _FakeSportSettingsService();
    final result = await openSheet(tester, service: service);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(service.undoCalls, hasLength(1));
    expect(service.undoCalls.single.currentValue, 252);
    expect(result.value, isTrue); // Undo pops the sheet with true
  });

  testWidgets('a failed undo shows an error via snackbar', (tester) async {
    final service = _FakeSportSettingsService(
      undoError: StateError('network'),
    );
    await openSheet(tester, service: service);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.textContaining("Couldn't undo"), findsOneWidget);
  });

  testWidgets('cancel pops without calling the service', (tester) async {
    final service = _FakeSportSettingsService();
    final result = await openSheet(tester, service: service);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(service.applyCalls, isEmpty);
    expect(result.value, isFalse);
  });
}

class _Result {
  bool? value;
}
