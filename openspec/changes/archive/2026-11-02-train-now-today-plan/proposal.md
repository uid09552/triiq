# Proposal

## Why

Train Now ignores what is already planned for today. An athlete with a session in their TriIQ plan or Intervals.icu calendar opens Train Now and gets a blank form that proposes something unrelated. When today's session doesn't fit (no time, wrong weather, tired legs), the useful question is "what can I do instead?", and the answer should be able to take today's slot.

## What Changes

- **Today's training on top**: Train Now first shows today's planned training sessions from the merged planned-items source (TriIQ plan sessions and, when copied, Intervals.icu events), one card each: sport, name, duration, TSS, source (TriIQ plan / Intervals.icu, sent or not), and the steps.
- **One main button that adapts**:
  - With a session planned today, it reads **Find alternative**. The agent proposes an alternative to the selected session, using it as the reference (similar training effect and load unless the athlete's recent data says otherwise). Sport, duration and intensity start from that session and stay editable.
  - With nothing planned today, it reads **Propose training**, as today.
- **Replace or add**: when creating the alternative, the preview offers **Replace today's session** (default) or **Add alongside**.
  - Replacing a TriIQ plan session updates that session in place (same plan, week and date; new content). Its Intervals.icu event, if any, is swapped.
  - Replacing an Intervals.icu event creates the new workout and then deletes the old event.
- The proposal and its Create / Google Calendar actions keep working as they do now, below the cards.

## Capabilities

### New Capabilities
- `train-now`: today's planned sessions on Train Now, the adaptive button, alternative proposals and replacing or adding.

### Modified Capabilities

None. No `train-now` spec exists yet, and it reads planned items through `calendar-sources` (from `plan-to-calendar`) without changing it.

## Impact

- Code:
  - `lib/screens/today/train_now_screen.dart`: today's cards, button, prompt, replace choice in the preview.
  - New `lib/screens/today/planned_session_card.dart`.
  - `PlansRepository.replaceSessionContent` (new) and a `PlanActions.replaceSession` helper (upstream first, then local, then `PlanChanges`).
  - Intervals.icu event replacement via the existing create + delete.
  - l10n (en, de).
- No schema change. It depends on `plan-to-calendar` (`PlannedItemsRepository`, `PlanChanges`, the send setting), which is implemented.
- Docs: `docs/okf.md` Train Now section.
