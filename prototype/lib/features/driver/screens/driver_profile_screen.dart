import 'package:flutter/material.dart';
import 'package:medirapid/core/routes/app_routes.dart';
import 'package:medirapid/features/driver/widgets/driver_page_scaffold.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DriverPageScaffold(
      title: 'Driver Profile',
      backRoute: AppRoutes.driverHome,
      showBottomNavigationBar: false,
      actions: IconButton(
        tooltip: 'Settings',
        icon: const Icon(Icons.settings_outlined),
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.driverSettings);
        },
      ),
      body: SafeArea(child: Container()),
    );
  }
}
