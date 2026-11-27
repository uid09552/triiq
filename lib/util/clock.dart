import 'package:flutter/foundation.dart';

/// The app's "now". Everything reads the time through [clockNow], so a test
/// can pin the date with [debugSetClock] instead of depending on the day it
/// runs (issue #121). In the app it is simply [DateTime.now].
DateTime clockNow() => _override?.call() ?? DateTime.now();

DateTime Function()? _override;

/// Pins [clockNow] to [now] (or a function of time) for tests; `null`
/// restores the real clock.
@visibleForTesting
void debugSetClock(DateTime Function()? now) => _override = now;
