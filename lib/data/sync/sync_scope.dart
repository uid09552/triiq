/// How much history a sync should cover, anchored on today.
enum SyncScope { today, month, year, all }

extension SyncScopeLabel on SyncScope {
  String get label => switch (this) {
    SyncScope.today => 'Today',
    SyncScope.month => 'This month',
    SyncScope.year => 'This year',
    SyncScope.all => 'Everything (initial sync)',
  };
}
