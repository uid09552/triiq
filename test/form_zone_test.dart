import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/evaluation/form_zone.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/widgets/stat_tile.dart';

void main() {
  test('zones follow form as a percentage of fitness', () {
    FormZone? z(double ctl, double atl) => formZoneOf(ctl, atl);
    expect(z(50, 35), FormZone.transition); // +30 %
    expect(z(50, 45), FormZone.fresh); // +10 %
    expect(z(50, 50), FormZone.grey); // 0 %
    expect(z(50, 60), FormZone.optimal); // −20 %
    expect(z(50, 70), FormZone.highRisk); // −40 %
    // Fits a low CTL too: −8 on a CTL of 20 is −40 %, on 80, −7 is −9 %.
    expect(z(20, 28), FormZone.highRisk);
    expect(z(80, 87), FormZone.grey);
    expect(formZoneOf(null, 40), isNull);
    expect(formZoneOf(0, 10), isNull);
  });

  testWidgets('a compact tile with onInfo shows ⓘ and opens the explainer', (
    t,
  ) async {
    var opened = 0;
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SizedBox(
            width: 180,
            child: StatTile(
              label: 'Fitness · CTL',
              value: '62',
              compact: true,
              icon: Icons.trending_up,
              onTap: () {},
              onInfo: () => opened++,
              infoTooltip: 'What does Fitness mean?',
            ),
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(
      t.getSize(find.byKey(const ValueKey('tile-info'))).height,
      greaterThanOrEqualTo(28),
    );
    await t.tap(find.byKey(const ValueKey('tile-info')));
    expect(opened, 1);
  });
}
