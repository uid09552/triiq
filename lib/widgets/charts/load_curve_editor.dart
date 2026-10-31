import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../plan/load_curve.dart';
import '../../plan/load_curve_controller.dart';
import '../../plan/plan_models.dart';

/// The load graph: one column per plan week on a TSS axis. Each week has a
/// shaded band (80-120% of its proposed TSS) and the proposal is a dashed
/// ramp through the weeks. Press anywhere in a column and drag up or down;
/// the point follows the drag (it doesn't jump to the finger), snaps to
/// 5 TSS with a haptic tick, and a label shows week, TSS, share of the
/// proposal and the change against the week before. Tap a week to fine-tune
/// it with the buttons or the arrow keys; every column is also a
/// screen-reader slider.
///
/// Painted by hand like the app's other charts.
class LoadCurveEditor extends StatefulWidget {
  const LoadCurveEditor({
    super.key,
    required this.controller,
    this.height = 240,
    this.onChanged,
    this.readOnly = false,
    this.highlight = const {},
  });

  final LoadCurveController controller;
  final double height;

  /// Called after a drag ends or a step, undo or reset changes the load —
  /// when the caller should persist it.
  final VoidCallback? onChanged;

  /// A picture of the curve, e.g. on a chat proposal card: no dragging, no
  /// buttons, no keyboard.
  final bool readOnly;

  /// 0-based weeks to mark as changed (a proposal's edits).
  final Set<int> highlight;

  /// Narrowest a week's column gets; below this the graph scrolls.
  static const minColumnWidth = 40.0;
  static const axisWidth = 44.0;
  static const topPad = 34.0;
  static const bottomPad = 24.0;

  /// TSS per button press / arrow key, and with Shift.
  static const smallStep = 5.0;
  static const largeStep = 25.0;

  @override
  State<LoadCurveEditor> createState() => _LoadCurveEditorState();
}

/// The value axis: a TSS range rounded out to a readable tick step.
class _TssAxis {
  _TssAxis(this.min, this.max, this.step);

  factory _TssAxis.of(LoadCurveController c) {
    var low = double.infinity;
    var high = 0.0;
    for (var i = 0; i < c.weeks; i++) {
      final band = c.bandFor(i);
      low = math.min(low, band.low);
      high = math.max(high, band.high);
    }
    if (!low.isFinite) return _TssAxis(0, 100, 25);
    final range = math.max(1.0, high - low);
    final step = [25.0, 50.0, 100.0, 200.0, 500.0].firstWhere(
      (s) => range / s <= 5,
      orElse: () => 1000,
    );
    final min = math.max(0.0, (low / step).floor() * step);
    var max = (high / step).ceil() * step;
    if (max <= min) max = min + step;
    return _TssAxis(min, max, step);
  }

  final double min;
  final double max;
  final double step;

  double y(double tss, double height) {
    final plot = height - LoadCurveEditor.topPad - LoadCurveEditor.bottomPad;
    return LoadCurveEditor.topPad + (max - tss) / (max - min) * plot;
  }

  Iterable<double> get ticks sync* {
    for (var v = min; v <= max + 1e-9; v += step) {
      yield v;
    }
  }
}

class _LoadCurveEditorState extends State<LoadCurveEditor> {
  final _focus = FocusNode(debugLabel: 'LoadCurveEditor');
  int? _dragging;
  double _dragStartY = 0;
  double _dragStartTss = 0;

  /// Fixed while dragging so the scale doesn't shift under the finger.
  _TssAxis? _dragAxis;

  LoadCurveController get _c => widget.controller;

  double get _plotHeight =>
      widget.height - LoadCurveEditor.topPad - LoadCurveEditor.bottomPad;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _step(int index, double delta) {
    if (_c.stepTss(index, delta)) {
      HapticFeedback.selectionClick();
      widget.onChanged?.call();
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final selected = _c.selected;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight) {
      final delta = key == LogicalKeyboardKey.arrowLeft ? -1 : 1;
      final next = ((selected ?? (delta > 0 ? -1 : _c.weeks)) + delta).clamp(
        0,
        _c.weeks - 1,
      );
      _c.select(next);
      return KeyEventResult.handled;
    }
    if (selected == null) return KeyEventResult.ignored;
    final size = HardwareKeyboard.instance.isShiftPressed
        ? LoadCurveEditor.largeStep
        : LoadCurveEditor.smallStep;
    if (key == LogicalKeyboardKey.arrowUp) {
      _step(selected, size);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _step(selected, -size);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _confirmReset() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.planCurveResetTitle),
        content: Text(l10n.planCurveResetBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.planCurveReset),
          ),
        ],
      ),
    );
    if (ok == true) {
      _c.reset();
      widget.onChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) => _build(context),
    );
  }

  int _percent(int i) => (_c.factors[i] * 100).round();

  Widget _build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final targets = _c.targets;
    final flags = _c.flags;
    final phases = _c.phases;
    final selected = _c.selected;
    final axis = _dragAxis ?? _TssAxis.of(_c);

    final colors = _CurveColors(
      line: scheme.primary,
      point: scheme.primary,
      warning: scheme.error,
      recovery: scheme.tertiary,
      grid: scheme.outlineVariant,
      proposal: scheme.outline,
      band: scheme.primary.withValues(alpha: 0.07),
      label: scheme.onSurfaceVariant,
      strongLabel: scheme.onSurface,
      bubble: scheme.inverseSurface,
      bubbleText: scheme.onInverseSurface,
      selection: scheme.primary.withValues(alpha: 0.08),
      highlight: scheme.tertiary.withValues(alpha: 0.14),
    );

    final graph = LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth - LoadCurveEditor.axisWidth;
        final column = math.max(
          LoadCurveEditor.minColumnWidth,
          available / math.max(1, _c.weeks),
        );
        final width = column * _c.weeks;

        final plot = SizedBox(
          width: width,
          height: widget.height,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _CurvePainter(
                    axis: axis,
                    proposal: _c.proposal,
                    bands: [for (var i = 0; i < _c.weeks; i++) _c.bandFor(i)],
                    targets: targets,
                    flags: flags,
                    phases: phases,
                    selected: selected,
                    dragging: _dragging,
                    highlight: widget.highlight,
                    column: column,
                    colors: colors,
                    textStyle: theme.textTheme.labelSmall!,
                    weekLabel: (i) => l10n.planCurveWeekShort(i + 1),
                    dragLabel: (i) => l10n.planCurveDragLabel(
                      i + 1,
                      _percent(i),
                      targets[i].round(),
                    ),
                    deltaLabel: (i) =>
                        l10n.planCurveDelta(_signedPercent(_c.deltaFor(i))),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < _c.weeks; i++)
                    widget.readOnly
                        ? SizedBox(width: column, height: widget.height)
                        : _column(context, l10n, i, column, targets[i], axis),
                ],
              ),
            ],
          ),
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: LoadCurveEditor.axisWidth,
              height: widget.height,
              child: CustomPaint(
                painter: _AxisPainter(
                  axis: axis,
                  colors: colors,
                  textStyle: theme.textTheme.labelSmall!,
                ),
              ),
            ),
            Expanded(
              child: width > available + 0.5
                  ? SingleChildScrollView(
                      key: const ValueKey('load-curve-scroll'),
                      scrollDirection: Axis.horizontal,
                      child: plot,
                    )
                  : plot,
            ),
          ],
        );
      },
    );

    final selectedFlags = selected == null
        ? const <WeekLimit>{}
        : flags[selected];
    final band = selected == null ? null : _c.bandFor(selected);
    if (widget.readOnly) return graph;
    return Focus(
      focusNode: _focus,
      onKeyEvent: _onKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          graph,
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  selected == null
                      ? l10n.planCurveSelectHint
                      : l10n.planCurveDragLabel(
                          selected + 1,
                          _percent(selected),
                          targets[selected].round(),
                        ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: selected == null
                        ? scheme.onSurfaceVariant
                        : scheme.onSurface,
                    fontWeight: selected == null ? null : FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.planCurveDecrease,
                onPressed: selected == null ||
                        targets[selected] <= band!.low + 1e-9
                    ? null
                    : () => _step(selected, -LoadCurveEditor.smallStep),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              IconButton(
                tooltip: l10n.planCurveIncrease,
                onPressed: selected == null ||
                        targets[selected] >= band!.high - 1e-9
                    ? null
                    : () => _step(selected, LoadCurveEditor.smallStep),
                icon: const Icon(Icons.add_circle_outline),
              ),
              IconButton(
                tooltip: l10n.planCurveUndo,
                onPressed: _c.canUndo
                    ? () {
                        _c.undo();
                        widget.onChanged?.call();
                      }
                    : null,
                icon: const Icon(Icons.undo),
              ),
              TextButton(
                onPressed: _c.isDefault ? null : _confirmReset,
                child: Text(l10n.planCurveReset),
              ),
            ],
          ),
          for (final flag in selectedFlags)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: scheme.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      warningLabel(l10n, flag, _c.limits.rampCap),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _column(
    BuildContext context,
    AppLocalizations l10n,
    int i,
    double width,
    double target,
    _TssAxis axis,
  ) {
    String tss(double v) => l10n.planCurveTssValue(v.round());
    final up = _c.snapTss(i, target + LoadCurveEditor.smallStep);
    final down = _c.snapTss(i, target - LoadCurveEditor.smallStep);
    return SizedBox(
      width: width,
      height: widget.height,
      child: Semantics(
        slider: true,
        label: l10n.planCurveWeekSemantics(i + 1, _percent(i)),
        value: tss(target),
        increasedValue: tss(up),
        decreasedValue: tss(down),
        onIncrease: () => _step(i, LoadCurveEditor.smallStep),
        onDecrease: () => _step(i, -LoadCurveEditor.smallStep),
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeUpDown,
          child: GestureDetector(
            key: ValueKey('load-week-$i'),
            behavior: HitTestBehavior.opaque,
            // Measure the drag from where the finger went down, so the
            // touch slop isn't lost and the point never jumps.
            dragStartBehavior: DragStartBehavior.down,
            onTap: () {
              _focus.requestFocus();
              _c.select(i);
            },
            onVerticalDragStart: (details) {
              _focus.requestFocus();
              _dragStartY = details.localPosition.dy;
              _dragStartTss = _c.targets[i];
              setState(() {
                _dragging = i;
                _dragAxis = axis;
              });
              _c.beginDrag(i);
            },
            onVerticalDragUpdate: (details) {
              final frozen = _dragAxis ?? axis;
              final dy = details.localPosition.dy - _dragStartY;
              final next =
                  _dragStartTss - dy / _plotHeight * (frozen.max - frozen.min);
              if (_c.dragTss(i, next)) HapticFeedback.selectionClick();
            },
            onVerticalDragEnd: (_) => _endDrag(),
            onVerticalDragCancel: _endDrag,
          ),
        ),
      ),
    );
  }

  void _endDrag() {
    final index = _dragging;
    if (index == null) return;
    _c.endDrag();
    final moved = (_c.targets[index] - _dragStartTss).abs() > 1e-9;
    setState(() {
      _dragging = null;
      _dragAxis = null;
    });
    if (moved) widget.onChanged?.call();
  }
}

/// "+8" / "-12" — a fraction as a signed whole percent.
String _signedPercent(double fraction) {
  final pct = (fraction * 100).round();
  return pct > 0 ? '+$pct' : '$pct';
}

/// What a warning means, for the editor and the Plan screen.
String warningLabel(AppLocalizations l10n, WeekLimit limit, double rampCap) =>
    switch (limit) {
      WeekLimit.weeklyIncrease => l10n.planWarnRamp((rampCap * 100).round()),
      WeekLimit.ctlRamp => l10n.planWarnCtl,
      WeekLimit.hours => l10n.planWarnHours,
      WeekLimit.none => '',
    };

class _CurveColors {
  const _CurveColors({
    required this.line,
    required this.point,
    required this.warning,
    required this.recovery,
    required this.grid,
    required this.proposal,
    required this.band,
    required this.label,
    required this.strongLabel,
    required this.bubble,
    required this.bubbleText,
    required this.selection,
    required this.highlight,
  });

  final Color line;
  final Color point;
  final Color warning;
  final Color recovery;
  final Color grid;
  final Color proposal;
  final Color band;
  final Color label;
  final Color strongLabel;
  final Color bubble;
  final Color bubbleText;
  final Color selection;
  final Color highlight;
}

class _AxisPainter extends CustomPainter {
  _AxisPainter({
    required this.axis,
    required this.colors,
    required this.textStyle,
  });

  final _TssAxis axis;
  final _CurveColors colors;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    for (final v in axis.ticks) {
      final y = axis.y(v, size.height);
      final tp = TextPainter(
        text: TextSpan(
          text: '${v.round()}',
          style: textStyle.copyWith(color: colors.label),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width - 6, y - tp.height / 2));
    }
    // Unit above the top tick.
    final unit = TextPainter(
      text: TextSpan(
        text: 'TSS',
        style: textStyle.copyWith(
          color: colors.strongLabel,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    unit.paint(canvas, Offset(size.width - unit.width - 6, 4));
  }

  @override
  bool shouldRepaint(_AxisPainter old) =>
      old.axis.min != axis.min ||
      old.axis.max != axis.max ||
      old.colors.label != colors.label;
}

class _CurvePainter extends CustomPainter {
  _CurvePainter({
    required this.axis,
    required this.proposal,
    required this.bands,
    required this.targets,
    required this.flags,
    required this.phases,
    required this.selected,
    required this.dragging,
    required this.column,
    required this.colors,
    required this.textStyle,
    required this.weekLabel,
    required this.dragLabel,
    required this.deltaLabel,
    this.highlight = const {},
  });

  final _TssAxis axis;
  final List<double> proposal;
  final List<({double low, double high})> bands;
  final List<double> targets;
  final List<Set<WeekLimit>> flags;
  final List<String> phases;
  final int? selected;
  final int? dragging;
  final double column;
  final _CurveColors colors;
  final TextStyle textStyle;
  final String Function(int) weekLabel;
  final String Function(int) dragLabel;
  final String Function(int) deltaLabel;
  final Set<int> highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    double y(double tss) => axis.y(tss, h);
    double x(int i) => (i + 0.5) * column;

    // A proposal's changed weeks.
    for (final i in highlight) {
      if (i < 0 || i >= targets.length) continue;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            i * column + 2,
            LoadCurveEditor.topPad - 8,
            column - 4,
            h - LoadCurveEditor.topPad - LoadCurveEditor.bottomPad + 16,
          ),
          const Radius.circular(8),
        ),
        Paint()..color = colors.highlight,
      );
    }

    final focus = dragging ?? selected;
    if (focus != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            focus * column + 2,
            LoadCurveEditor.topPad - 8,
            column - 4,
            h - LoadCurveEditor.topPad - LoadCurveEditor.bottomPad + 16,
          ),
          const Radius.circular(8),
        ),
        Paint()..color = colors.selection,
      );
    }

    final grid = Paint()
      ..color = colors.grid
      ..strokeWidth = 1;
    for (final v in axis.ticks) {
      canvas.drawLine(Offset(0, y(v)), Offset(size.width, y(v)), grid);
    }

    // Each week's allowed band.
    final bandPaint = Paint()..color = colors.band;
    for (var i = 0; i < bands.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            x(i) - column * 0.3,
            y(bands[i].high),
            x(i) + column * 0.3,
            y(bands[i].low),
          ),
          const Radius.circular(4),
        ),
        bandPaint,
      );
    }

    // The proposal: a dashed ramp.
    final dash = Paint()
      ..color = colors.proposal
      ..strokeWidth = 1.5;
    for (var i = 0; i + 1 < proposal.length; i++) {
      final a = Offset(x(i), y(proposal[i]));
      final b = Offset(x(i + 1), y(proposal[i + 1]));
      final length = (b - a).distance;
      final dir = (b - a) / length;
      for (var d = 0.0; d < length; d += 8) {
        canvas.drawLine(a + dir * d, a + dir * math.min(d + 4, length), dash);
      }
    }
    if (proposal.length == 1) {
      canvas.drawLine(
        Offset(x(0) - column * 0.3, y(proposal[0])),
        Offset(x(0) + column * 0.3, y(proposal[0])),
        dash,
      );
    }

    Offset point(int i) => Offset(x(i), y(targets[i]));

    // The athlete's curve.
    if (targets.length > 1) {
      final path = Path()..moveTo(point(0).dx, point(0).dy);
      for (var i = 1; i < targets.length; i++) {
        path.lineTo(point(i).dx, point(i).dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = colors.line
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round,
      );
    }

    for (var i = 0; i < targets.length; i++) {
      final p = point(i);
      final warn = flags[i].isNotEmpty;
      final recovery = phases[i] == recoveryPhase;
      final color = warn
          ? colors.warning
          : recovery
          ? colors.recovery
          : colors.point;
      final active = i == focus;
      final radius = i == dragging
          ? 9.0
          : active
          ? 7.0
          : 5.0;
      canvas.drawCircle(p, radius + 2.5, Paint()..color = colors.bubbleText);
      canvas.drawCircle(p, radius, Paint()..color = color);

      _text(
        canvas,
        '${targets[i].round()}',
        Offset(p.dx, p.dy - radius - 4),
        textStyle.copyWith(
          color: warn ? colors.warning : colors.strongLabel,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
        anchorBottom: true,
      );
      _text(
        canvas,
        weekLabel(i),
        Offset(p.dx, h - LoadCurveEditor.bottomPad + 6),
        textStyle.copyWith(
          color: active ? colors.strongLabel : colors.label,
          fontWeight: active ? FontWeight.w700 : null,
        ),
      );
    }

    final d = dragging;
    if (d != null) _bubble(canvas, size, point(d), d);
  }

  /// The floating label above the dragged point, kept inside the chart.
  void _bubble(Canvas canvas, Size size, Offset anchor, int i) {
    final style = textStyle.copyWith(color: colors.bubbleText);
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: dragLabel(i),
            style: style.copyWith(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: '\n${deltaLabel(i)}', style: style),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    const pad = 6.0;
    final w = tp.width + pad * 2;
    final hgt = tp.height + pad * 2;
    final left = (anchor.dx - w / 2)
        .clamp(0.0, math.max(0.0, size.width - w))
        .toDouble();
    // Above the point, or below it when there's no room.
    var top = anchor.dy - hgt - 22;
    if (top < 0) top = anchor.dy + 16;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, w, hgt),
        const Radius.circular(8),
      ),
      Paint()..color = colors.bubble,
    );
    tp.paint(canvas, Offset(left + pad, top + pad));
  }

  void _text(
    Canvas canvas,
    String text,
    Offset center,
    TextStyle style, {
    bool anchorBottom = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final dy = anchorBottom ? center.dy - tp.height : center.dy;
    tp.paint(canvas, Offset(center.dx - tp.width / 2, dy));
  }

  @override
  bool shouldRepaint(_CurvePainter old) => true;
}
