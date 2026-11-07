import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../agent/chat_handoff.dart';
import '../../agent/llm_settings.dart';
import '../../agent/training_agent.dart';
import '../../evaluation/weekly_review.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/main_navigation.dart';
import '../../widgets/markdown_reply.dart';
import '../../widgets/section_card.dart';
import '../../widgets/skeleton.dart';
import '../activities/session_analysis.dart';

/// A week against its plan: per-day planned and done, compliance, the 80/20
/// split, load against recent weeks and the fitness change — all from the
/// cache, so it works offline — plus a next-week note from the agent,
/// labelled as its inference and only when a provider is set up.
class WeeklyReviewScreen extends StatefulWidget {
  const WeeklyReviewScreen({
    super.key,
    this.loader,
    this.agentFactory,
    this.settings,
    this.initialWeek,
  });

  /// Test seams; the app uses the defaults.
  final WeeklyReviewLoader? loader;
  final TrainingAgent Function()? agentFactory;
  final LlmSettings? settings;
  final DateTime? initialWeek;

  @override
  State<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends State<WeeklyReviewScreen> {
  late final _loader = widget.loader ?? WeeklyReviewLoader();
  late final _settings = widget.settings ?? LlmSettings.instance;
  late DateTime _week = startOfWeek(widget.initialWeek ?? DateTime.now());
  WeeklyReview? _review;
  String? _error;
  String _note = '';
  bool _noteBusy = false;
  StreamSubscription<AgentEvent>? _noteSub;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    _noteSub?.cancel();
    setState(() {
      _review = null;
      _error = null;
      _note = '';
      _noteBusy = false;
    });
    try {
      final review = await _loader.load(_week);
      if (!mounted) return;
      setState(() => _review = review);
      if (_settings.isConfigured) _askNote(review);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  void _shift(int weeks) {
    _week = _week.add(Duration(days: 7 * weeks));
    _load();
  }

  /// The figures the next-week note (and a chat about the week) is based on.
  static String summaryJson(WeeklyReview r) => jsonEncode({
    'week_start': isoDate(r.weekStart),
    'planned_sessions': r.plannedSessions,
    'completed_planned_sessions': r.completedPlanned,
    'missed_sessions': [
      for (final d in r.days)
        for (final m in d.missed)
          {'date': d.date.toIso8601String().substring(0, 10), 'name': m.name},
    ],
    'compliance': r.compliance,
    'load_tss': r.load,
    'planned_load_tss': r.plannedLoad,
    'recent_average_load_tss': r.recentAverageLoad?.round(),
    'intensity_seconds': r.split == null
        ? null
        : {
            'low': r.split!.low,
            'moderate': r.split!.moderate,
            'high': r.split!.high,
          },
    'sessions_without_zone_data': r.sessionsWithoutZones,
    'outside_80_20': r.outside8020,
    'ctl_change': r.ctlChange,
    'atl_change': r.atlChange,
    'form_end': r.formEnd,
  });

  void _askNote(WeeklyReview review) {
    final agent = (widget.agentFactory ?? TrainingAgent.new)();
    agent.attachedContext = summaryJson(review);
    setState(() => _noteBusy = true);
    try {
      _noteSub = agent
          .send(
            'From the weekly review figures attached, write a short note '
            '(at most 4 bullet points) on what to change next week. Use only '
            'those figures and your tools; say when data is missing.',
          )
          .listen(
            (e) {
              if (e is AgentTextDelta && mounted) {
                setState(() => _note += e.text);
              }
            },
            onError: (_) {
              if (mounted) setState(() => _noteBusy = false);
            },
            onDone: () {
              if (mounted) setState(() => _noteBusy = false);
            },
            cancelOnError: true,
          );
    } catch (_) {
      setState(() => _noteBusy = false);
    }
  }

  void _openInChat(WeeklyReview review) {
    final l10n = AppLocalizations.of(context)!;
    ChatHandoff.instance.open(
      ChatTopic(
        title: l10n.weeklyReviewTopic(
          DateFormat.MMMd(
            Localizations.localeOf(context).toString(),
          ).format(review.weekStart),
        ),
        context: summaryJson(review),
        draft: l10n.weeklyReviewChatDraft(
          DateFormat.MMMd(
            Localizations.localeOf(context).toString(),
          ).format(review.weekStart),
        ),
      ),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
    MainNavigation.instance.openTab(MainNavigation.chatTab);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final day = DateFormat.E(locale);
    final range = DateFormat.MMMd(locale);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final r = _review;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.weeklyReviewTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l10n.previousWeek,
                onPressed: () => _shift(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${range.format(_week)} – '
                  '${range.format(_week.add(const Duration(days: 6)))}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: l10n.nextWeek,
                onPressed: () => _shift(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          if (_error != null)
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          if (r == null && _error == null)
            const Column(
              children: [
                SkeletonCard(height: 90, lines: 2),
                SizedBox(height: 16),
                SkeletonCard(height: 90, lines: 2),
              ],
            ),
          if (r != null) ...[
            SectionCard(
              icon: Icons.checklist,
              title: l10n.weeklyCompliance,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.compliance == null
                        ? l10n.weeklyNothingPlanned
                        : l10n.weeklyComplianceValue(
                            (r.compliance! * 100).round(),
                            r.completedPlanned,
                            r.plannedSessions,
                          ),
                    key: const ValueKey('weekly-compliance'),
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    l10n.weeklyLoadValue(r.load, r.plannedLoad),
                    style: muted,
                  ),
                  const SizedBox(height: 8),
                  for (final d in r.days)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 40, child: Text(day.format(d.date))),
                          Expanded(
                            child: Text(
                              [
                                for (final a in d.done)
                                  '✓ ${a.name ?? a.type ?? ''}',
                                for (final m in d.missed)
                                  l10n.weeklyMissed(m.name ?? m.type ?? ''),
                                if (d.done.isEmpty && d.planned.isEmpty) '—',
                              ].join('\n'),
                              style: d.missed.isEmpty
                                  ? null
                                  : TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.stacked_bar_chart,
              title: l10n.weeklySplitTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntensitySplitBar(split: r.split),
                  if (r.outside8020)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        l10n.weeklyOutside8020(
                          (r.split!.lowShare! * 100).round(),
                        ),
                        key: const ValueKey('weekly-8020-flag'),
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  if (r.sessionsWithoutZones > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        l10n.weeklyNoZones(r.sessionsWithoutZones),
                        style: muted,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.trending_up,
              title: l10n.weeklyTrendTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.loadVsRecent == null
                        ? l10n.weeklyNoHistory
                        : l10n.weeklyVsRecent(
                            _signed((r.loadVsRecent! * 100).round()),
                            r.recentAverageLoad!.round(),
                          ),
                    key: const ValueKey('weekly-trend'),
                  ),
                  if (r.ctlChange != null)
                    Text(
                      l10n.weeklyFitness(
                        _signedD(r.ctlChange!),
                        _signedD(r.atlChange ?? 0),
                        r.formEnd?.toStringAsFixed(0) ?? '–',
                      ),
                    ),
                ],
              ),
            ),
            if (_settings.isConfigured) ...[
              const SizedBox(height: 16),
              SectionCard(
                icon: Icons.lightbulb_outline,
                title: l10n.weeklyNoteTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.weeklyNoteLabel, style: muted),
                    const SizedBox(height: 6),
                    if (_noteBusy && _note.isEmpty)
                      const LinearProgressIndicator()
                    else
                      MarkdownReply(
                        key: const ValueKey('weekly-note'),
                        text: _note,
                      ),
                    TextButton.icon(
                      onPressed: () => _openInChat(r),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: Text(l10n.weeklyOpenInChat),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  static String _signed(int v) => v > 0 ? '+$v' : '$v';
  static String _signedD(double v) =>
      v > 0 ? '+${v.toStringAsFixed(1)}' : v.toStringAsFixed(1);
}
