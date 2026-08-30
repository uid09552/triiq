import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'data/intervals_session.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Fire-and-forget: re-validates a saved API key (if any) in the
  // background so the UI isn't blocked on startup. IntervalsSession is a
  // ChangeNotifier, so screens update reactively once it resolves.
  unawaited(IntervalsSession.instance.restore());
  runApp(const TriiqApp());
}
