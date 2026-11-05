import 'package:flutter/material.dart';
import 'package:medirapid/core/routes/app_routes.dart';
import 'package:medirapid/features/auth/providers/driver_verification_provider.dart';
import 'package:medirapid/features/driver/widgets/driver_page_scaffold.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final verificationProvider = DriverVerificationProvider.instance;

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedBuilder(
                animation: verificationProvider,
                builder: (context, _) {
                  final isApproved = verificationProvider.isApproved;
                  final statusText = isApproved
                      ? 'Verification status: Approved'
                      : 'Verification status: Pending';
                  final statusColor = isApproved
                      ? const Color(0xFF166534)
                      : const Color(0xFF075985);
                  final statusBackground = isApproved
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFE0F2FE);
                  final statusBorder = isApproved
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFBAE6FD);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: statusBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isApproved
                              ? Icons.verified_rounded
                              : Icons.info_outline_rounded,
                          color: statusColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEAF2FF),
                    child: Icon(Icons.fact_check_outlined, color: Colors.blue),
                  ),
                  title: const Text('Driver verification'),
                  subtitle: const Text(
                    'Submit and review your emergency driver documents',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.driverVerification);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
