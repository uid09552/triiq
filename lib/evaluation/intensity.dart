/// Time in each intensity domain for one activity: the three-zone model the
/// training reference uses, folded out of whatever zone settings the athlete
/// has. Shared by the agent's tools and the session evaluation so both say
/// the same thing about the same activity.
class IntensitySplit {
  const IntensitySplit(this.low, this.moderate, this.high, this.source);

  /// Seconds below the first threshold, in the threshold domain, above it.
  final int low;
  final int moderate;
  final int high;

  /// Which zone series the split came from — power, heart rate or pace.
  final String source;

  int get total => low + moderate + high;

  double? get lowShare => total == 0 ? null : low / total;
  double? get moderateShare => total == 0 ? null : moderate / total;
  double? get highShare => total == 0 ? null : high / total;

  IntensitySplit operator +(IntensitySplit other) => IntensitySplit(
    low + other.low,
    moderate + other.moderate,
    high + other.high,
    source == other.source ? source : 'mixed',
  );
}

/// The split for an activity's cached JSON, or `null` when it carries no
/// zone times at all (manual entries, sessions with neither power nor HR).
/// Power wins over heart rate, heart rate over pace.
IntensitySplit? intensityOf(Map<String, dynamic> raw) {
  final power = _zoneTimeSeconds(raw['icu_zone_times']);
  if (power != null) return _split(power, 'power');
  final hr = _zoneTimeSeconds(raw['icu_hr_zone_times']);
  if (hr != null) return _split(hr, 'heart rate');
  final pace = _zoneTimeSeconds(raw['pace_zone_times']);
  if (pace != null) return _split(pace, 'pace');
  return null;
}

/// Intervals.icu reports power zone times as `[{id, secs}]` and HR/pace
/// zone times as a plain `[secs]`.
List<int>? _zoneTimeSeconds(Object? value) {
  if (value is! List || value.isEmpty) return null;
  final seconds = <int>[];
  for (final entry in value) {
    if (entry is num) {
      seconds.add(entry.toInt());
    } else if (entry is Map && entry['secs'] is num) {
      seconds.add((entry['secs'] as num).toInt());
    } else {
      return null;
    }
  }
  return seconds.any((s) => s > 0) ? seconds : null;
}

IntensitySplit _split(List<int> zones, String source) {
  int sum(int from, int to) {
    var total = 0;
    for (var i = from; i < to && i < zones.length; i++) {
      total += zones[i];
    }
    return total;
  }

  // Three-zone physiology mapped onto however many zones the athlete's
  // settings use: the two easiest zones sit below the first threshold,
  // the next two span the threshold domain, the rest are above it.
  if (zones.length <= 3) {
    return IntensitySplit(sum(0, 1), sum(1, 2), sum(2, zones.length), source);
  }
  if (zones.length == 4) {
    return IntensitySplit(sum(0, 2), sum(2, 3), sum(3, 4), source);
  }
  return IntensitySplit(sum(0, 2), sum(2, 4), sum(4, zones.length), source);
}
