import 'package:flutter/material.dart';

import '../../client/intervalls/intervalls_client.dart';
import '../../data/intervals_session.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/athlete_avatar.dart';
import '../../widgets/section_card.dart';
import '../activities/activity_icons.dart';

/// Athlete details: who the athlete is (picture, location, age), their body
/// stats from the latest cached wellness record, and their per-sport
/// thresholds.
///
/// Thresholds come from two places, in this order: the sport settings
/// Intervals.icu holds *now* (fetched with the athlete record on connect),
/// and — for anything those don't carry — the values frozen into the most
/// recent analysed activity for that sport, which is where the training
/// agent reads them from too. Each row says which it is.
class AthleteDetailScreen extends StatefulWidget {
  const AthleteDetailScreen({super.key});

  @override
  State<AthleteDetailScreen> createState() => _AthleteDetailScreenState();
}

class _AthleteDetailScreenState extends State<AthleteDetailScreen> {
  final _session = IntervalsSession.instance;
  final _wellnessRepository = WellnessRepository();
  final _activitiesRepository = ActivitiesRepository();

  bool _loading = true;
  _BodyStats? _body;
  List<_SportThresholds> _sports = const [];

  @override
  void initState() {
    super.initState();
    _session.addListener(_onSessionChanged);
    _load();
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    if (!_session.isConnected) {
      setState(() => _loading = false);
      return;
    }

    // The athlete record is loaded on connect, but a session restored from
    // the vault may still be fetching it — ask again so this screen isn't
    // the one place that shows nothing.
    if (_session.athlete == null) {
      await _session.refreshAthlete();
    }

    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 365));
    final wellness = await _wellnessRepository.getRange(
      isoDate(start),
      isoDate(today),
    );
    final activities = await _activitiesRepository.getRange(
      isoDate(start),
      isoDate(today),
    );

    double? weight;
    String? weightDate;
    int? restingHr;
    String? restingHrDate;
    double? hrv;
    String? hrvDate;
    // Newest first: the first non-null value found per field is the most
    // recent one logged for it.
    for (final record in wellness.reversed) {
      final raw = record.raw;
      final w = _asDouble(raw['weight']);
      if (weight == null && w != null) {
        weight = w;
        weightDate = record.date;
      }
      final hr = raw['restingHR'];
      if (restingHr == null && hr is num) {
        restingHr = hr.toInt();
        restingHrDate = record.date;
      }
      final h = _asDouble(raw['hrv']);
      if (hrv == null && h != null) {
        hrv = h;
        hrvDate = record.date;
      }
      if (weight != null && restingHr != null && hrv != null) break;
    }

    // activities is oldest-first, so a later row for the same sport
    // overwrites an earlier one — the map ends up holding each sport's
    // thresholds as of its newest cached activity.
    final bySport = <String, _SportThresholds>{};
    for (final activity in activities) {
      final sport = activity.type;
      if (sport == null) continue;
      final raw = activity.raw;
      final thresholds = _SportThresholds(
        sport: sport,
        asOf: activity.date,
        ftp: _asNum(raw['icu_ftp'] ?? raw['icu_pm_ftp']),
        wPrime: _asNum(raw['icu_w_prime']),
        lthr: _asNum(raw['lthr']),
        maxHr: _asNum(raw['athlete_max_hr']),
        thresholdPaceMPerS: _asDouble(raw['threshold_pace']),
        weightKg: _asDouble(raw['icu_weight']),
      );
      if (thresholds.hasAny) bySport[sport] = thresholds;
    }

    // Live sport settings win over anything frozen into an old activity.
    for (final settings
        in _session.athlete?.sportSettings ?? const <SportSettings>[]) {
      for (final type in settings.types ?? const <SportSettingsTypesEnum>[]) {
        final sport = type.value;
        final current = _SportThresholds(
          sport: sport,
          asOf: null,
          ftp: settings.ftp,
          indoorFtp: settings.indoorFtp,
          wPrime: settings.wPrime,
          lthr: settings.lthr,
          maxHr: settings.maxHr,
          thresholdPaceMPerS: settings.thresholdPace,
          weightKg: bySport[sport]?.weightKg,
        );
        if (current.hasAny) bySport[sport] = current;
      }
    }

    if (!mounted) return;
    setState(() {
      _body = _BodyStats(
        weightKg: weight ?? _session.athlete?.icuWeight,
        weightDate: weight != null ? weightDate : null,
        restingHr: restingHr ?? _session.athlete?.icuRestingHr,
        restingHrDate: restingHr != null ? restingHrDate : null,
        hrv: hrv,
        hrvDate: hrvDate,
      );
      _sports = bySport.values.toList()
        ..sort((a, b) => a.sport.compareTo(b.sport));
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final connected = _session.isConnected;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleAthlete)),
      body: !connected
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.connectForAthleteDetails,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ProfileHeader(athlete: _session.athlete),
                const SizedBox(height: 16),
                SectionCard(
                  icon: Icons.monitor_weight_outlined,
                  title: l10n.bodyAndWellness,
                  child: _body == null || !_body!.hasAny
                      ? Text(
                          l10n.noWellnessCached,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_body!.weightKg != null)
                              _Row(
                                label: l10n.weightLabel,
                                value:
                                    '${_body!.weightKg!.toStringAsFixed(1)} kg',
                                asOf: _body!.weightDate,
                              ),
                            if (_body!.restingHr != null)
                              _Row(
                                label: l10n.restingHrLabel,
                                value: '${_body!.restingHr} bpm',
                                asOf: _body!.restingHrDate,
                              ),
                            if (_body!.hrv != null)
                              _Row(
                                label: l10n.hrvLabel,
                                value: _body!.hrv!.toStringAsFixed(0),
                                asOf: _body!.hrvDate,
                              ),
                          ],
                        ),
                ),
                if (_sports.isEmpty) ...[
                  const SizedBox(height: 16),
                  SectionCard(
                    icon: Icons.speed_outlined,
                    title: l10n.thresholdsTitle,
                    child: Text(
                      l10n.noActivitiesForThresholds,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
                for (final sport in _sports) ...[
                  const SizedBox(height: 16),
                  SectionCard(
                    icon: activityTypeIcon(sport.sport),
                    title: sport.sport,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sport.ftp != null)
                          _Row(
                            label: 'FTP',
                            value: '${sport.ftp} W',
                            asOf: sport.asOf,
                          ),
                        if (sport.indoorFtp != null)
                          _Row(
                            label: l10n.indoorFtpLabel,
                            value: '${sport.indoorFtp} W',
                            asOf: sport.asOf,
                          ),
                        if (sport.wPrime != null)
                          _Row(
                            label: "W'",
                            value: '${sport.wPrime} J',
                            asOf: sport.asOf,
                          ),
                        if (sport.lthr != null)
                          _Row(
                            label: 'LTHR',
                            value: '${sport.lthr} bpm',
                            asOf: sport.asOf,
                          ),
                        if (sport.maxHr != null)
                          _Row(
                            label: l10n.maxHrLabel,
                            value: '${sport.maxHr} bpm',
                            asOf: sport.asOf,
                          ),
                        if (sport.thresholdPaceMPerS != null)
                          _Row(
                            label: l10n.thresholdPaceLabel,
                            value: _formatPace(sport.thresholdPaceMPerS!),
                            asOf: sport.asOf,
                          ),
                        if (sport.weightKg != null)
                          _Row(
                            label: l10n.weightAsAnalysedLabel,
                            value: '${sport.weightKg!.toStringAsFixed(1)} kg',
                            asOf: sport.asOf,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          sport.asOf == null
                              ? l10n.thresholdsFromSettings
                              : l10n.thresholdsFromActivity,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  static double? _asDouble(Object? value) =>
      value is num ? value.toDouble() : null;

  static num? _asNum(Object? value) => value is num ? value : null;

  /// Intervals.icu stores threshold pace as metres/second; athletes think in
  /// minutes per kilometre.
  static String _formatPace(double metersPerSecond) {
    if (metersPerSecond <= 0) return '—';
    final secsPerKm = 1000 / metersPerSecond;
    final minutes = secsPerKm ~/ 60;
    final seconds = (secsPerKm % 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')} /km';
  }
}

/// Picture, name and the identity facts Intervals.icu knows: where the
/// athlete is, how old they are, which sports they have set up.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.athlete});

  final WithSportSettings? athlete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final session = IntervalsSession.instance;

    final facts = <String>[
      if (_location(athlete) != null) _location(athlete)!,
      if (_age(athlete) != null) l10n.ageYears(_age(athlete)!),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.tertiary],
        ),
      ),
      child: Row(
        children: [
          const AthleteAvatar(size: 64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.athleteName ?? l10n.titleAthlete,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  facts.isEmpty
                      ? l10n.athleteIdLine(session.athleteId ?? '—')
                      : facts.join(' · '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String? _location(WithSportSettings? athlete) {
    final parts = [
      if (athlete?.city != null && athlete!.city!.isNotEmpty) athlete.city!,
      if (athlete?.country != null && athlete!.country!.isNotEmpty)
        athlete.country!,
    ];
    return parts.isEmpty ? null : parts.join(', ');
  }

  /// Intervals.icu stores the birthday as `yyyy-MM-dd`; anything else (or a
  /// blank) simply means no age is shown.
  static int? _age(WithSportSettings? athlete) {
    final birthday = athlete?.icuDateOfBirth;
    if (birthday == null || birthday.length < 10) return null;
    final date = DateTime.tryParse(birthday.substring(0, 10));
    if (date == null) return null;
    final now = DateTime.now();
    var years = now.year - date.year;
    final hadBirthday =
        now.month > date.month ||
        (now.month == date.month && now.day >= date.day);
    if (!hadBirthday) years--;
    return years >= 0 && years < 130 ? years : null;
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.asOf});

  final String label;
  final String value;
  final String? asOf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (asOf != null) ...[
            const SizedBox(width: 8),
            Text(
              l10n.asOfDate(formatIsoDate(asOf!)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BodyStats {
  const _BodyStats({
    this.weightKg,
    this.weightDate,
    this.restingHr,
    this.restingHrDate,
    this.hrv,
    this.hrvDate,
  });

  final double? weightKg;
  final String? weightDate;
  final int? restingHr;
  final String? restingHrDate;
  final double? hrv;
  final String? hrvDate;

  bool get hasAny => weightKg != null || restingHr != null || hrv != null;
}

class _SportThresholds {
  const _SportThresholds({
    required this.sport,
    required this.asOf,
    this.ftp,
    this.indoorFtp,
    this.wPrime,
    this.lthr,
    this.maxHr,
    this.thresholdPaceMPerS,
    this.weightKg,
  });

  final String sport;

  /// The date of the activity these were read from, or `null` when they are
  /// the athlete's current Intervals.icu sport settings.
  final String? asOf;

  final num? ftp;
  final num? indoorFtp;
  final num? wPrime;
  final num? lthr;
  final num? maxHr;
  final double? thresholdPaceMPerS;
  final double? weightKg;

  bool get hasAny =>
      ftp != null ||
      indoorFtp != null ||
      wPrime != null ||
      lthr != null ||
      maxHr != null ||
      thresholdPaceMPerS != null ||
      weightKg != null;
}
