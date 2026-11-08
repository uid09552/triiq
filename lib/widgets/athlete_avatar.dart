import 'package:flutter/material.dart';

import '../data/intervals_session.dart';

/// The athlete's Intervals.icu profile picture, falling back to a
/// gradient-filled initial (or a person icon when there's no name yet).
///
/// The picture is fetched straight from the URL Intervals.icu returns and
/// left to Flutter's image cache; a failure to load is not worth an error
/// state, so it quietly shows the fallback.
class AthleteAvatar extends StatelessWidget {
  const AthleteAvatar({super.key, this.size = 40, this.onSurface = false});

  final double size;

  /// Render for a surface background (cards, lists) rather than for the
  /// coloured gradient headers, where white-on-gradient is what reads.
  final bool onSurface;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final session = IntervalsSession.instance;

    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final url = session.athleteAvatarUrl;
        final name = session.athleteName?.trim();
        final initial = name != null && name.isNotEmpty
            ? name.characters.first.toUpperCase()
            : null;

        return Container(
          width: size,
          height: size,
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onSurface
                ? colorScheme.primaryContainer
                : Colors.white.withValues(alpha: 0.2),
            gradient: onSurface
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.tertiary],
                  ),
          ),
          child: url != null
              ? Image.network(
                  url,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, _) => _fallback(context, initial),
                )
              : _fallback(context, initial),
        );
      },
    );
  }

  Widget _fallback(BuildContext context, String? initial) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = onSurface
        ? colorScheme.onPrimaryContainer
        : Colors.white;
    if (initial == null) {
      return Icon(Icons.person, size: size * 0.5, color: foreground);
    }
    return Text(
      initial,
      style: TextStyle(
        color: foreground,
        fontSize: size * 0.42,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
