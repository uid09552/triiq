import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/sync/sync_service.dart';

/// The Today screen needs the whole current week (for the week's TSS total)
/// *and* tomorrow (for tomorrow's planned session) in one fetch.
void main() {
  test('covers Monday to Sunday of the current week', () {
    // Wednesday 2026-08-26.
    final (oldest, newest) = SyncService.todayWindow(DateTime(2026, 8, 26));

    expect(oldest, DateTime(2026, 8, 24)); // Monday
    expect(newest, DateTime(2026, 8, 30)); // Sunday
  });

  test('on Monday, still starts that Monday', () {
    final (oldest, newest) = SyncService.todayWindow(DateTime(2026, 8, 24));

    expect(oldest, DateTime(2026, 8, 24));
    expect(newest, DateTime(2026, 8, 30));
  });

  test('on Sunday, extends past the week end to include tomorrow', () {
    // Sunday 2026-08-30: tomorrow is next month's Monday, outside the week.
    final (oldest, newest) = SyncService.todayWindow(DateTime(2026, 8, 30));

    expect(oldest, DateTime(2026, 8, 24));
    expect(newest, DateTime(2026, 8, 31));
  });

  test('ignores the time of day', () {
    final (oldest, newest) =
        SyncService.todayWindow(DateTime(2026, 8, 26, 23, 59, 59));

    expect(oldest, DateTime(2026, 8, 24));
    expect(newest, DateTime(2026, 8, 30));
  });
}
