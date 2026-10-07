import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medirapid/features/auth/screens/driver_verification_screen.dart';

void main() {
  testWidgets(
    'driver verification shows required documents and validates form',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DriverVerificationScreen()),
      );

      expect(find.text('Driver Verification'), findsOneWidget);
      for (final documentTitle in [
        'Driving licence',
        'Vehicle registration certificate',
        'Vehicle insurance',
        'Ambulance permit / fitness certificate',
      ]) {
        await tester.scrollUntilVisible(
          find.text(documentTitle),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(documentTitle), findsOneWidget);
      }

      await tester.ensureVisible(find.text('Submit for Verification'));
      await tester.tap(find.text('Submit for Verification'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your licence number'), findsOneWidget);
      expect(
        find.text('Enter your vehicle registration number'),
        findsOneWidget,
      );
    },
  );
}
