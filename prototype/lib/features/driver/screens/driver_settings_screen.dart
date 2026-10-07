import 'package:flutter/material.dart';
import 'package:medirapid/core/routes/app_routes.dart';
import 'package:medirapid/features/driver/providers/driver_provider.dart';
import 'package:medirapid/features/driver/widgets/driver_page_scaffold.dart';
import 'package:medirapid/shared/models/settings_item.dart';

class DriverSettingsScreen extends StatelessWidget {
  const DriverSettingsScreen({super.key});

  Future<void> _logOut(BuildContext context) async {
    final shouldLogOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logging out?'),
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
      DriverProvider.instance.resetSession();
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

    return DriverPageScaffold(
      title: 'Settings',
      backRoute: AppRoutes.driverProfile,
      showBottomNavigationBar: false,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                itemCount: settings.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = settings[index];
                  return ListTile(
                    leading: Icon(item.icon, color: Colors.blueAccent),
                    title: Text(item.title),
                    subtitle: Text(item.subtitle),
                    trailing: const Icon(Icons.chevron_right),
                  );
                },
              ),
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
