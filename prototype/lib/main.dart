import 'package:flutter/material.dart';
import 'package:emergency_prototype/core/routes/app_routes.dart';
import 'package:emergency_prototype/core/theme/app_theme.dart';
import 'package:emergency_prototype/features/auth/role_selection_screen.dart';
import 'package:emergency_prototype/features/driver/screens/driver_home_screen.dart';
import 'package:emergency_prototype/features/patient/screens/patient_home_screen.dart';

void main() => runApp(const EmergencyApp());

class EmergencyApp extends StatelessWidget {
  const EmergencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Help',
      theme: AppTheme.theme,
      //debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.roleSelection,
      routes: {
        AppRoutes.roleSelection: (_) => const RoleSelectionScreen(),
        AppRoutes.patientHome: (_) => const PatientHomeScreen(),
        AppRoutes.driverHome: (_) => const DriverHomeScreen(),
      },
    );
  }
}
