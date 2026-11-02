import '../../l10n/app_localizations.dart';

String eventCategoryLabel(AppLocalizations l10n, String? category) =>
    switch (category) {
      'RACE_A' => l10n.eventCategoryRaceA,
      'RACE_B' => l10n.eventCategoryRaceB,
      'RACE_C' => l10n.eventCategoryRaceC,
      'NOTE' => l10n.eventCategoryNote,
      'HOLIDAY' => l10n.eventCategoryHoliday,
      'SICK' => l10n.eventCategorySick,
      'INJURED' => l10n.eventCategoryInjured,
      'TARGET' => l10n.eventCategoryTarget,
      'SEASON_START' => l10n.eventCategorySeasonStart,
      _ => category ?? '',
    };
