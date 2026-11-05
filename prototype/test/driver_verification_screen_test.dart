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

  testWidgets('driver identifiers accept Indian formats and reject malformed input', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: DriverVerificationScreen()),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'ABC123');
    await tester.enterText(fields.at(1), 'MH-12-1234567');
    await tester.ensureVisible(find.text('Submit for Verification'));
    await tester.tap(find.text('Submit for Verification'));
    await tester.pumpAndSettle();

    expect(
      find.text('Licence number must contain 8–20 letters or numbers.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Enter a valid Indian registration number'),
      findsOneWidget,
    );

    await tester.enterText(fields.at(0), 'dl-0420110149646');
    await tester.enterText(fields.at(1), '22 bh 1234 aa');
    expect(
      tester.widget<TextFormField>(fields.at(0)).controller!.text,
      'DL-0420110149646',
    );
    expect(
      tester.widget<TextFormField>(fields.at(1)).controller!.text,
      '22 BH 1234 AA',
    );
    await tester.ensureVisible(find.text('Submit for Verification'));
    await tester.tap(find.text('Submit for Verification'));
    await tester.pumpAndSettle();

    expect(
      find.text('Licence number must contain 8–20 letters or numbers.'),
      findsNothing,
    );
    expect(
      find.textContaining('Enter a valid Indian registration number'),
      findsNothing,
    );
    expect(
      find.text('Please attach all required documents to continue.'),
      findsOneWidget,
    );
  });
}
