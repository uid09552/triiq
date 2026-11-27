# Proposal

## Why

A finished session only gets attention if the athlete goes looking for it in Activities. The moment they open the app after training is when feedback lands best: did it go to plan, was anything a personal best, is the aerobic engine improving, and do they need to go easy tomorrow? The data for all of this is already in the cache (or computed by Intervals.icu), but nothing brings it forward.

## What Changes

- **New-training pop-up**:
  - When the app opens (cold start or resume) and today's sync brought sessions the athlete hasn't seen, a sheet shows them, one page per session if there are several.
  - Each page has the session's details, the existing evaluation (verdict with reasons, intensity split), plus the insights below.
  - **OK** marks all of today's shown sessions as seen. Each session is shown once, and only on the day it happened. Older sessions never pop up.
  - "Details" opens the full activity screen.
- **Personal bests**: best efforts Intervals.icu flags on the activity (`icu_achievements`, e.g. best 5-minute power, fastest 5 km) are listed in the pop-up and on the activity detail, with the previous best when reported.
- **Fitness marker**: for easy sessions, the efficiency factor (power or pace per heart rate, `icu_efficiency_factor`) compared with the median of the same sport's easy sessions over the last 6 weeks ("+4% vs your 6-week median"), shown only when at least 4 such sessions exist.
- **Recovery hint**:
  - The pop-up gives an estimated recovery time from the session's TSS and the current form (TSB), labelled as an estimate with its rule shown.
  - If tomorrow's planned session is hard and the recovery would run into it, the hint says so and offers **Find alternative** (Train Now) for tomorrow.
- A switch in Settings → Notifications & insights turns the pop-up off. The insights still show on the activity detail.

## Capabilities

### New Capabilities
- `training-insights`: the once-per-day new-training pop-up and seen tracking, personal bests, the efficiency-factor trend, and the recovery hint.

### Modified Capabilities

None. It builds on `session-evaluation` (evaluator, activity detail) and `calendar-sources` (planned items) without changing their requirements.

## Impact

- **Code:**
  - New `lib/evaluation/insights.dart` (PBs, EF trend and recovery, all pure).
  - New `lib/screens/insights/new_training_sheet.dart`, a seen store (SharedPreferences), and a hook in the shell after the open-sync of `AutoSyncService`.
  - An insights section on `ActivityDetailScreen`, a Settings switch, a knowledge `okf-rules` addition for recovery hours, and l10n (en, de).
- No schema change; no new API calls.
- **Risk:** the exact shape of `icu_achievements` isn't documented in our spec. It's parsed defensively and checked against the live suite.
- **Docs:** `docs/okf.md` (Today/app-open behaviour, Activities, training knowledge).
