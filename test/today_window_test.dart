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

  group('monthWindow', () {
    test('covers the whole current month', () {
      // Wednesday 2026-08-26, a week wholly inside August.
      final (oldest, newest) = SyncService.monthWindow(DateTime(2026, 8, 26));

      expect(oldest, DateTime(2026, 8, 1));
      expect(newest, DateTime(2026, 8, 31));
    });

    test('reaches back when the current week starts in the previous month', () {
      // Tuesday 2026-09-01: that week started Monday 2026-08-31.
      final (oldest, newest) = SyncService.monthWindow(DateTime(2026, 9, 1));

      expect(oldest, DateTime(2026, 8, 31));
      expect(newest, DateTime(2026, 9, 30));
    });

    test('reaches forward when tomorrow is next month', () {
      // Monday 2026-08-31: tomorrow, and the rest of that week, is September.
      final (oldest, newest) = SyncService.monthWindow(DateTime(2026, 8, 31));

      expect(oldest, DateTime(2026, 8, 1));
      expect(newest, DateTime(2026, 9, 6));
    });
  });
}
