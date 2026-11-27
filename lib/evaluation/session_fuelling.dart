import '../data/models/local_event.dart';

/// Carbohydrate to take in *during* a planned session, as a range in grams
/// per hour, from common sports-nutrition guidance (about 30–60 g/h for
/// 1–2.5 h, 60–90 g/h beyond; hard sessions of 75 min and up count as
/// long). Fuelling for training only — never a calorie or weight target.
/// `null` for sessions too short to need it.
({int low, int high})? sessionFuelling(LocalEvent e) {
  if (!e.isTraining) return null;
  final secs = e.plannedTime ?? 0;
  final minutes = secs / 60;
  if (minutes < 75) return null;
  final load = e.plannedLoad ?? 0;
  final perHour = secs > 0 ? load / (secs / 3600) : 0;
  final hard = perHour >= 70;
  if (minutes >= 150 || (hard && minutes >= 120)) return (low: 60, high: 90);
  return (low: 30, high: 60);
}
