import 'dart:convert';

import 'package:triiq/client/intervalls/intervalls_client.dart';

/// A wellness/load record for a single day, cached from Intervals.icu.
class LocalWellness {
  const LocalWellness({
    required this.date,
    required this.ctl,
    required this.atl,
    required this.ctlLoad,
    required this.atlLoad,
    required this.rampRate,
    required this.raw,
    required this.syncedAt,
  });

  /// ISO-8601 local day, e.g. `2026-08-30`. Intervals.icu returns this as
  /// the wellness record's `id`.
  final String date;
  final double? ctl;
  final double? atl;
  final double? ctlLoad;
  final double? atlLoad;
  final double? rampRate;

  /// The full API response, for fields not promoted to their own column.
  final Map<String, dynamic> raw;
  final DateTime syncedAt;

  factory LocalWellness.fromApi(Wellness wellness) {
    final json = wellness.toJson();
    return LocalWellness(
      date: wellness.id ?? '',
      ctl: wellness.ctl,
      atl: wellness.atl,
      ctlLoad: wellness.ctlLoad,
      atlLoad: wellness.atlLoad,
      rampRate: wellness.rampRate,
      raw: json,
      syncedAt: DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
    'date': date,
    'ctl': ctl,
    'atl': atl,
    'ctl_load': ctlLoad,
    'atl_load': atlLoad,
    'ramp_rate': rampRate,
    'raw': jsonEncode(raw),
    'synced_at': syncedAt.millisecondsSinceEpoch,
  };

  factory LocalWellness.fromMap(Map<String, Object?> map) => LocalWellness(
    date: map['date'] as String,
    ctl: map['ctl'] as double?,
    atl: map['atl'] as double?,
    ctlLoad: map['ctl_load'] as double?,
    atlLoad: map['atl_load'] as double?,
    rampRate: map['ramp_rate'] as double?,
    raw: jsonDecode(map['raw'] as String) as Map<String, dynamic>,
    syncedAt: DateTime.fromMillisecondsSinceEpoch(map['synced_at'] as int),
  );
}
