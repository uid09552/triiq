import 'package:flutter/material.dart';

import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../sync/sync_screen.dart';

/// Submenu for functionality that doesn't need a permanent bottom-nav slot.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MoreTile(
          icon: Icons.person_outline,
          title: 'Profile',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _MoreTile(
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _MoreTile(
          icon: Icons.cloud_sync_outlined,
          title: 'Sync',
          subtitle: 'Pull training data from Intervals.icu',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SyncScreen()),
          ),
        ),
        const SizedBox(height: 20),
        const _MoreTile(
          icon: Icons.event_note_outlined,
          title: 'Training plans',
          subtitle: 'Coming soon',
          enabled: false,
        ),
        const SizedBox(height: 10),
        const _MoreTile(
          icon: Icons.fitness_center_outlined,
          title: 'Gear',
          subtitle: 'Coming soon',
          enabled: false,
        ),
      ],
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        enabled: enabled,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: enabled
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: enabled ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: enabled ? const Icon(Icons.chevron_right) : null,
      ),
    );
  }
}
