import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medirapid/core/routes/app_routes.dart';
import 'package:medirapid/features/auth/screens/driver_verification_pending_screen.dart';

void main() {
  test('driver dashboard is blocked until verification is explicitly approved', () {
    AppRoutes.markDriverVerificationPending();
    expect(AppRoutes.driverVerificationApproved, isFalse);

    AppRoutes.approveDriverVerification();
    expect(AppRoutes.driverVerificationApproved, isTrue);

    AppRoutes.markDriverVerificationPending();
    expect(AppRoutes.driverVerificationApproved, isFalse);
  });

  testWidgets('verification pending screen shows status information', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: DriverVerificationPendingScreen()),
    );

    expect(find.text('Verification pending'), findsOneWidget);
    expect(
      find.textContaining('Your documents have been submitted successfully'),
      findsOneWidget,
    );
    expect(find.text('Done'), findsOneWidget);
  });
}
