import 'package:url_launcher/url_launcher.dart';

import 'markdown_to_text.dart';

/// Opens Google Calendar's "add event" flow with the given details
/// prefilled, via the `calendar.google.com/calendar/render` URL — no OAuth
/// or Google API client needed, in keeping with this app's "no custom
/// backend, talk to the third party directly" design.
///
/// `LaunchMode.externalApplication` hands the link to the OS the same way
/// tapping it anywhere else would (see "Open in Intervals.icu" on the
/// activity detail screen for the same pattern), so it opens the Google
/// Calendar app when one's installed and registered for it, and the browser
/// otherwise. Returns whether the link was launched.
///
/// [description] is run through [markdownToPlainText] first — Google
/// Calendar's description field doesn't render Markdown, so an agent reply
/// passed straight through would show up with literal `**`, `#` and `|`.
///
/// Set [allDay] for something with no time of day — a planned session
/// Intervals.icu stores at midnight belongs on the day, not at 00:00.
Future<bool> launchGoogleCalendarEvent({
  required String title,
  required String description,
  required DateTime start,
  required Duration duration,
  bool allDay = false,
}) {
  final end = start.add(duration);
  // All-day spans are whole dates and the end is exclusive, so a one-day
  // entry runs from its date to the next.
  final days = duration.inDays < 1 ? 1 : duration.inDays;
  final dates = allDay
      ? '${_dayStamp(start)}/${_dayStamp(start.add(Duration(days: days)))}'
      : '${_utcStamp(start)}/${_utcStamp(end)}';

  final uri = Uri.https('calendar.google.com', '/calendar/render', {
    'action': 'TEMPLATE',
    'text': title,
    'dates': dates,
    'details': markdownToPlainText(description),
  });
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// `YYYYMMDD`, the all-day form of the same parameter — the local date, not
/// UTC: an all-day entry shouldn't slide a day either way.
String _dayStamp(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}'
      '${two(date.month)}${two(date.day)}';
}

/// `YYYYMMDDTHHMMSSZ`, the format Google Calendar's render URL expects.
String _utcStamp(DateTime date) {
  final utc = date.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${utc.year.toString().padLeft(4, '0')}${two(utc.month)}'
      '${two(utc.day)}T${two(utc.hour)}${two(utc.minute)}${two(utc.second)}Z';
}
