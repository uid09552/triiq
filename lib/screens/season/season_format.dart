/// `1:23:45` or `23:45` for [seconds].
String clock(num seconds) {
  final s = seconds.round();
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = s % 60;
  final mm = m.toString().padLeft(h > 0 ? 2 : 1, '0');
  final ss = sec.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

/// `4:35 /km` style pace from seconds per km.
String paceKm(double secPerKm) => '${clock(secPerKm)} /km';

/// `1:42 /100 m` style swim pace.
String pace100(double secPer100) => '${clock(secPer100)} /100 m';

String signed(double v) => '${v >= 0 ? '+' : ''}${v.round()}';
