import '../data/intervals_session.dart';
import '../data/models/local_activity.dart';
import '../data/repositories/activities_repository.dart';

/// What the first sync shows about the athlete's data: things the app
/// cannot fix, but can explain.
class SetupFindings {
  const SetupFindings({
    this.stravaActivities = 0,
    this.missingThresholds = const [],
  });

  /// Activities Intervals.icu holds only as Strava stubs (its API does not
  /// hand those out), so they have no data here.
  final int stravaActivities;

  /// Sports (`Ride`, `Run`, `Swim`) without the threshold the load metrics
  /// need: FTP, or threshold pace.
  final List<String> missingThresholds;

  bool get isEmpty => stravaActivities == 0 && missingThresholds.isEmpty;
}

/// Activities that reached Intervals.icu through Strava.
int stravaSourcedCount(Iterable<LocalActivity> activities) => activities
    .where((a) => '${a.raw['source']}'.toUpperCase() == 'STRAVA')
    .length;

/// Sports among [sports] whose settings lack the threshold for them.
List<String> sportsMissingThreshold(
  Iterable<String> sports,
  ({int? ftp, double? thresholdPace})? Function(String sport) settingsOf,
) => [
  for (final sport in sports)
    if (_missing(sport, settingsOf(sport))) sport,
];

bool _missing(String sport, ({int? ftp, double? thresholdPace})? s) {
  if (s == null) return true;
  return sport == 'Ride' ? (s.ftp ?? 0) <= 0 : (s.thresholdPace ?? 0) <= 0;
}

/// Reads the synced activities and the athlete's sport settings.
Future<SetupFindings> checkSetup({
  required Iterable<String> sports,
  Future<List<LocalActivity>> Function()? activities,
  IntervalsSession? session,
}) async {
  final s = session ?? IntervalsSession.instance;
  final all = await (activities ?? ActivitiesRepository().getAll)();
  return SetupFindings(
    stravaActivities: stravaSourcedCount(all),
    missingThresholds: s.isConnected
        ? sportsMissingThreshold(sports, (sport) {
            final x = s.settingsForSport(sport);
            return x == null
                ? null
                : (ftp: x.ftp, thresholdPace: x.thresholdPace);
          })
        : const [],
  );
}
