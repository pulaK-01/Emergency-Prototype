import 'package:flutter/material.dart';
import 'package:medirapid/app.dart';
import 'package:medirapid/core/routes/app_routes.dart';
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

void main() {
  runApp(
    MediRapid(
      initialRoute: AppRoutes.patientHome,
      routes: {
        AppRoutes.roleSelection: (_) => const RoleSelectionScreen(),
        AppRoutes.patientHome: (_) => const PatientHomeScreen(),
        AppRoutes.patientSettings: (_) => const PatientSettingsScreen(),
        AppRoutes.driverVerification: (_) => const DriverVerificationScreen(),
        AppRoutes.driverVerificationPending: (_) =>
            const DriverVerificationPendingScreen(),
        AppRoutes.driverHome: (_) =>
            const DriverAccessGuard(child: DriverHomeScreen()),
        AppRoutes.driverDispatch: (_) =>
            const DriverAccessGuard(child: DriverDispatchScreen()),
        AppRoutes.driverCurrentTripFlow: (_) =>
            const DriverAccessGuard(child: DriverCurrentTripFlowScreen()),
        AppRoutes.driverTripHistory: (_) =>
            const DriverAccessGuard(child: DriverTripHistoryPage()),
        AppRoutes.driverProfile: (_) => const DriverProfileScreen(),
        AppRoutes.driverSettings: (_) => const DriverSettingsScreen(),
      },
    ),
  );
}
