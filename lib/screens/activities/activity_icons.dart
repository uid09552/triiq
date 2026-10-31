import 'package:flutter/material.dart';

/// Maps an Intervals.icu activity `type` (e.g. `Ride`, `VirtualRide`,
/// `Run`, `Swim`) to a representative icon. Falls back to a generic one for
/// the long tail of sport types Intervals.icu supports.
IconData activityTypeIcon(String? type) {
  final normalized = (type ?? '').toLowerCase();
  if (normalized.contains('ride') || normalized.contains('bike')) {
    return Icons.directions_bike_outlined;
  }
  if (normalized.contains('run') || normalized.contains('walk')) {
    return Icons.directions_run_outlined;
  }
  if (normalized.contains('swim')) return Icons.pool_outlined;
  if (normalized.contains('hike')) return Icons.terrain_outlined;
  if (normalized.contains('row')) return Icons.rowing_outlined;
  if (normalized.contains('ski') || normalized.contains('snowboard')) {
    return Icons.downhill_skiing_outlined;
  }
  if (normalized.contains('strength') || normalized.contains('weight')) {
    return Icons.fitness_center_outlined;
  }
  if (normalized.contains('yoga')) return Icons.self_improvement_outlined;
  return Icons.sports_score_outlined;
}

/// A colour per triathlon sport, readable on the light and dark surface;
/// other sports get the theme's secondary colour.
Color sportColor(String? type, ColorScheme scheme) {
  final dark = scheme.brightness == Brightness.dark;
  final normalized = (type ?? '').toLowerCase();
  if (normalized.contains('swim')) {
    return dark ? const Color(0xFF6EC6FF) : const Color(0xFF0277BD);
  }
  if (normalized.contains('ride') || normalized.contains('bike')) {
    return dark ? const Color(0xFFFFB74D) : const Color(0xFFE65100);
  }
  if (normalized.contains('run')) {
    return dark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
  }
  return scheme.secondary;
}

/// Formats an ISO `yyyy-MM-dd` string (as stored in `LocalActivity.date`)
/// as e.g. `Aug 30, 2026`, without pulling in `package:intl` for one format.
String formatIsoDate(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length != 3) return isoDate;
  final year = parts[0];
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (month == null || day == null || month < 1 || month > 12) return isoDate;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[month - 1]} $day, $year';
}

/// Formats a duration in seconds as `1h 23m` / `45m`.
String formatDurationSecs(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
}

/// Formats a distance in meters as `12.3 km`.
String formatDistanceMeters(double meters) =>
    '${(meters / 1000).toStringAsFixed(1)} km';
