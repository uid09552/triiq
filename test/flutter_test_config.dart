import 'dart:async';

import 'support/temp_database.dart';

/// Runs for every test file: points the shared database at a throwaway temp
/// file (and sets up the SQLite factory the desktop test VM needs), so a test
/// that reaches the database through a repository default neither fails
/// without a factory nor reads or writes a `triiq.db` in the working
/// directory.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  useTempAppDatabase();
  await testMain();
}
