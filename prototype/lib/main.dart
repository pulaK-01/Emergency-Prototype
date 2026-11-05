import 'package:flutter/material.dart';
import 'package:medirapid/core/routes/app_routes.dart';
import 'package:medirapid/core/theme/app_theme.dart';
import 'package:medirapid/features/auth/providers/driver_verification_provider.dart';
import 'package:medirapid/features/auth/screens/driver_verification_pending_screen.dart';
import 'package:medirapid/features/auth/screens/driver_verification_screen.dart';
import 'package:medirapid/features/auth/screens/role_selection_screen.dart';
import 'package:medirapid/features/driver/screens/driver_current_trip_flow_screen.dart';
import 'package:medirapid/features/driver/screens/driver_dispatch_screen.dart';
import 'package:medirapid/features/driver/screens/driver_home_screen.dart';
import 'package:medirapid/features/driver/screens/driver_profile_screen.dart';
import 'package:medirapid/features/driver/screens/driver_settings_screen.dart';
import 'package:medirapid/features/driver/screens/driver_trip_history_screen.dart';
import 'package:medirapid/features/patient/screens/patient_home_screen.dart';
import 'package:medirapid/features/patient/screens/patient_settings_screen.dart';

void main() => runApp(const MediRapid());

class DriverAccessGuard extends StatelessWidget {
  const DriverAccessGuard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DriverVerificationProvider.instance,
      builder: (context, _) {
        if (DriverVerificationProvider.instance.isApproved) {
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

class MediRapid extends StatelessWidget {
  const MediRapid({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediRapid',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.driverVerification,
      routes: {
        AppRoutes.roleSelection: (_) => const RoleSelectionScreen(),
        AppRoutes.patientHome: (_) => const PatientHomeScreen(),
        AppRoutes.patientSettings: (_) => const PatientSettingsScreen(),
        AppRoutes.driverVerification: (_) => const DriverVerificationScreen(),
        AppRoutes.driverVerificationPending: (_) =>
            const DriverVerificationPendingScreen(),
        AppRoutes.driverHome: (_) =>
            DriverAccessGuard(child: const DriverHomeScreen()),
        AppRoutes.driverDispatch: (_) =>
            DriverAccessGuard(child: const DriverDispatchScreen()),
        AppRoutes.driverCurrentTripFlow: (_) =>
            DriverAccessGuard(child: const DriverCurrentTripFlowScreen()),
        AppRoutes.driverTripHistory: (_) =>
            DriverAccessGuard(child: const DriverTripHistoryPage()),
        AppRoutes.driverProfile: (_) => const DriverProfileScreen(),
        AppRoutes.driverSettings: (_) => const DriverSettingsScreen(),
      },
    );
  }
}
