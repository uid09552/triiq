import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/athlete_avatar.dart';

/// Marks a More entry's page that is shown as a bottom-bar tab. Such a page
/// keeps its own top bar (title, its actions) and the shell hides its own;
/// [shellTabActions] adds the shell's profile button to that bar so every
/// tab has it in the same corner. Pushed, the same page has a back button
/// instead and no profile button.
class ShellTabScope extends InheritedWidget {
  const ShellTabScope({super.key, required super.child});

  static bool isTab(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellTabScope>() != null;

  @override
  bool updateShouldNotify(ShellTabScope oldWidget) => false;
}

/// The shell's profile / settings button, the right corner of every tab.
class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: AppLocalizations.of(context)!.profileAndSettingsTooltip,
    // The athlete's own picture once connected — the fastest way to see at
    // a glance which account the app is showing.
    icon: const AthleteAvatar(size: 34),
    onPressed: () => Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen())),
  );
}

/// What a page appends to its `AppBar.actions`: the profile button when it
/// is a tab ([ShellTabScope]), nothing when it was pushed.
List<Widget> shellTabActions(BuildContext context) =>
    ShellTabScope.isTab(context)
    ? const [ProfileButton(), SizedBox(width: 12)]
    : const [];
