import 'package:flutter/material.dart';

import '../../evaluation/readiness.dart';
import '../../l10n/app_localizations.dart';
import 'readiness_card.dart' show readinessColor;

String _fmt(double v, int digits) => v.toStringAsFixed(digits);

/// "7 h 30 min".
String readinessHours(double hours) {
  final minutes = (hours * 60).round();
  return '${minutes ~/ 60} h ${(minutes % 60).toString().padLeft(2, '0')} min';
}

/// How a signal's rating reads and what colour it gets: the label on the
/// detail screen and in a peek. With [signal], a missing baseline says how
/// far along it is ("Building baseline (9/21 days)").
(String, Color) readinessRatingStyle(
  AppLocalizations l10n,
  ColorScheme scheme,
  SignalRating rating, {
  ReadinessSignal? signal,
}) => switch (rating) {
  SignalRating.ok => (l10n.readinessRatingOk, Colors.green.shade600),
  SignalRating.caution => (
    l10n.readinessCaution,
    readinessColor(scheme, ReadinessLevel.caution),
  ),
  SignalRating.backOff => (
    l10n.readinessBackOff,
    readinessColor(scheme, ReadinessLevel.backOff),
  ),
  SignalRating.noBaseline => (
    signal?.baselineNeeded != null && signal?.baselineCount != null
        ? l10n.readinessRatingBuildingBaseline(
            signal!.baselineCount!,
            signal.baselineNeeded!,
          )
        : l10n.readinessRatingNoBaseline,
    scheme.onSurfaceVariant,
  ),
  SignalRating.missing => (
    l10n.readinessRatingMissing,
    scheme.onSurfaceVariant,
  ),
  SignalRating.excluded => (
    l10n.readinessRatingExcluded,
    scheme.onSurfaceVariant,
  ),
};

/// Today's value of [s] with its unit, or "—".
String readinessValueText(ReadinessSignal s) {
  final value = s.value;
  if (value == null) return '—';
  return switch (s.kind) {
    ReadinessSignalKind.hrv => '${_fmt(value, 0)} ms',
    ReadinessSignalKind.restingHr => '${_fmt(value, 0)} bpm',
    ReadinessSignalKind.sleep => readinessHours(value),
    ReadinessSignalKind.form => _fmt(value, 1),
    ReadinessSignalKind.subjective => _fmt(value, 0),
    ReadinessSignalKind.load => _fmt(value, 2),
    ReadinessSignalKind.device => _fmt(value, 0),
  };
}

/// How HRV / resting HR were rated: "3-day median 54 bpm vs usual 49 ± 2
/// (28 days) · today 56 bpm" — the raw reading only when it differs.
String? _smoothedText(AppLocalizations l10n, ReadinessSignal s, String unit) {
  final mean = s.mean, sd = s.sd, value = s.value, days = s.smoothingDays;
  if (mean == null || sd == null || value == null || days == null) {
    return null;
  }
  final today = s.todayValue;
  return [
    l10n.readinessSmoothedDetail(
      days,
      '${_fmt(value, 0)} $unit',
      _fmt(mean, 0),
      _fmt(sd, 0),
      s.baselineCount ?? 0,
    ),
    if (today != null && _fmt(today, 0) != _fmt(value, 0))
      l10n.readinessTodayRaw('${_fmt(today, 0)} $unit'),
  ].join(' · ');
}

/// The normal range of [s] in words ("Normal from 55 ms (avg 62 ms)"), or
/// null when it has none.
String? readinessRangeText(AppLocalizations l10n, ReadinessSignal s) {
  final mean = s.mean;
  final bound = s.okBound;
  final value = s.value;
  return switch (s.kind) {
    ReadinessSignalKind.hrv when mean != null && bound != null => [
      l10n.readinessRangeHrv(_fmt(bound, 0), _fmt(mean, 0)),
      ?_smoothedText(l10n, s, 'ms'),
    ].join(' · '),
    ReadinessSignalKind.restingHr when mean != null && bound != null => [
      l10n.readinessRangeRestingHr(_fmt(bound, 0), _fmt(mean, 0)),
      ?_smoothedText(l10n, s, 'bpm'),
    ].join(' · '),
    ReadinessSignalKind.sleep when bound != null => l10n.readinessRangeSleep(
      _fmt(bound, 1),
    ),
    ReadinessSignalKind.form when bound != null => l10n.readinessRangeForm(
      _fmt(bound, 0),
    ),
    ReadinessSignalKind.load when bound != null => [
      l10n.readinessRangeLoad(_fmt(bound, 2)),
      if (s.dayLoad != null) l10n.readinessLoadToday(_fmt(s.dayLoad!, 0)),
    ].join(' · '),
    ReadinessSignalKind.device when bound != null => l10n.readinessRangeDevice(
      _fmt(bound, 0),
    ),
    ReadinessSignalKind.subjective when value != null =>
      l10n.readinessSubjectiveValues(
        s.fatigue?.toString() ?? '—',
        s.soreness?.toString() ?? '—',
      ),
    _ => null,
  };
}
