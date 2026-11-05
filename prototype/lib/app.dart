import 'package:flutter/material.dart';
import 'package:medirapid/core/routes/app_routes.dart';
import 'package:medirapid/core/theme/app_theme.dart';
import 'package:medirapid/features/auth/providers/driver_verification_provider.dart';

const bool bypassDriverVerification = true;

class MediRapid extends StatelessWidget {
  const MediRapid({
    required this.routes,
    required this.initialRoute,
    super.key,
  });

  final Map<String, WidgetBuilder> routes;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediRapid',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: routes,
    );
  }
}

class DriverAccessGuard extends StatelessWidget {
  const DriverAccessGuard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DriverVerificationProvider.instance,
      builder: (context, _) {
        if (bypassDriverVerification ||
            DriverVerificationProvider.instance.isApproved) {
          return child;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;

          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Verification pending'),
              content: const Text(
                'Your driver verification is still pending. You cannot access the dashboard.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.driverProfile,
                      (route) => false,
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        });

        return const SizedBox.shrink();
      },
    );
  }
}
