import 'package:flutter_test/flutter_test.dart';
import 'package:medirapid/features/driver/models/trip_flow_model.dart';
import 'package:medirapid/features/driver/models/trip_model.dart';
import 'package:medirapid/features/driver/providers/driver_provider.dart';

void main() {
  test('driver can progress a request through trip completion', () {
    final driver = DriverProvider.instance;
    driver.resetSession();

    final request = driver.incomingRequests.single;
    driver.acceptRequest(request);
    expect(driver.tripStage, TripStage.navigatingToPickup);

    final activeTrip = driver.activeTrip;
    final overlappingRequest = Trip(
      id: 'AMB-1010',
      patientName: 'Test Patient',
      distanceKm: 2.0,
      requestedAt: DateTime.now(),
      pickup: 'Pickup',
      destination: 'Hospital',
      status: TripStatus.requested,
    );
    driver.addIncomingRequest(overlappingRequest);
    expect(driver.acceptRequest(overlappingRequest), isFalse);
    expect(driver.activeTrip, same(activeTrip));

    driver.markArrived();
    expect(driver.tripStage, TripStage.arrived);
    driver.beginAssessment();
    expect(driver.tripStage, TripStage.active);

    driver.setPatientAssessed(true);
    driver.setFirstAidGiven(true);
    driver.setPatientLoaded(true);
    expect(driver.isChecklistComplete, isTrue);

    driver.navigateToDestination();
    expect(driver.tripStage, TripStage.navigatingToDestination);
    driver.completeTrip();

    expect(driver.tripStage, TripStage.completed);
    expect(driver.completedTrips.single.status, TripStatus.completed);
    expect(driver.todayEarnings, 210);

    driver.resetSession();
  });
}
