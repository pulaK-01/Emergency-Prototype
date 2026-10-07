import 'package:flutter/material.dart';
import 'package:medirapid/core/routes/app_routes.dart';
import 'package:medirapid/shared/models/settings_item.dart';

class PatientSettingsScreen extends StatelessWidget {
  const PatientSettingsScreen({super.key});

  Future<void> _logOut(BuildContext context) async {
    final shouldLogOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will return to role selection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogOut == true && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.roleSelection,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = [
      const SettingsItem(
        icon: Icons.person_outline,
        title: 'Profile',
        subtitle: 'Edit your personal information',
      ),
      const SettingsItem(
        icon: Icons.emergency_outlined,
        title: 'Emergency Contacts',
        subtitle: 'Manage the people to contact in an emergency',
      ),
      const SettingsItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'Manage alerts and updates',
      ),
      const SettingsItem(
        icon: Icons.shield_outlined,
        title: 'Privacy & Security',
        subtitle: 'Manage your account security',
      ),
      const SettingsItem(
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'View FAQs and contact support',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: settings.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = settings[index];
                return ListTile(
                  leading: Icon(item.icon, color: Colors.redAccent),
                  title: Text(item.title),
                  subtitle: Text(item.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logOut(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
