import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/threshold_suggestions_service.dart';
import 'package:triiq/evaluation/performance_curves.dart';
import 'package:triiq/evaluation/threshold_suggestions.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/statistics/threshold_suggestion_card.dart';

class _FakeService extends ThresholdSuggestionsService {
  _FakeService(this.suggestions);

  final List<ThresholdSuggestion> suggestions;

  @override
  Future<List<ThresholdSuggestion>> load() async => suggestions;
}

ThresholdSuggestion _rideUp() => const ThresholdSuggestion(
  sport: CurveSport.ride,
  field: 'ftp',
  currentValue: 252,
  candidateValue: 262,
  direction: ThresholdDirection.up,
  basisKind: ThresholdBasisKind.rideSeasonModel,
);

ThresholdSuggestion _rideDown() => const ThresholdSuggestion(
  sport: CurveSport.ride,
  field: 'ftp',
  currentValue: 252,
  candidateValue: 230,
  direction: ThresholdDirection.down,
  basisKind: ThresholdBasisKind.rideRecentModel,
);

void main() {
  Future<void> pump(WidgetTester tester, List<ThresholdSuggestion> suggestions) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: ThresholdSuggestionsSection(service: _FakeService(suggestions)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows nothing when there are no suggestions', (tester) async {
    await pump(tester, const []);

    expect(find.text('Threshold suggestions'), findsNothing);
  });

  testWidgets('shows an up suggestion with its change and basis', (tester) async {
    await pump(tester, [_rideUp()]);

    expect(find.text('Threshold suggestions'), findsOneWidget);
    expect(find.text('252 W → 262 W'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    expect(
      find.textContaining("This season's model fit is 4.0% above"),
      findsOneWidget,
    );
  });

  testWidgets('shows a down suggestion worded as likely dropped', (tester) async {
    await pump(tester, [_rideDown()]);

    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    expect(find.textContaining('likely dropped'), findsOneWidget);
  });

  testWidgets('shows multiple suggestions at once', (tester) async {
    await pump(tester, [_rideUp(), _rideDown()]);

    expect(find.text('Review'), findsNWidgets(2));
  });
}
