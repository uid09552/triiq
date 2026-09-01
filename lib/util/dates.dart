/// Date helpers shared by the screens that read the local cache.
///
/// Everything in SQLite is keyed by an ISO `yyyy-MM-dd` *local* day string,
/// because that is what Intervals.icu returns (`start_date_local`) and what
/// range queries compare lexicographically. These are the two conversions
/// that kept being rewritten per screen.
library;

/// `2026-08-31` — the cache's key format.
String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Midnight local, so day arithmetic isn't skewed by the current time.
DateTime dateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

/// The Monday of [date]'s week — Intervals.icu weeks start on Monday.
DateTime startOfWeek(DateTime date) =>
    dateOnly(date).subtract(Duration(days: date.weekday - 1));
