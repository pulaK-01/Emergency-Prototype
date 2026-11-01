import 'package:flutter_test/flutter_test.dart';
import 'package:medirapid/features/driver/models/trip_flow_model.dart';
import 'package:medirapid/features/driver/models/trip_model.dart';
import 'package:medirapid/features/driver/providers/driver_provider.dart';

void main() {
  test('driver can progress a request through trip completion', () {
    final driver = DriverProvider.instance;
    driver.resetSession();

    expect(driver.incomingRequests, isEmpty);
    final offlineRequest = Trip(
      id: 'OFFLINE-REQUEST',
      patientName: 'Test Patient',
      distanceKm: 4.2,
      requestedAt: DateTime.now(),
      pickup: 'Pickup',
      destination: 'Hospital',
      status: TripStatus.requested,
    );
    expect(driver.addIncomingRequest(offlineRequest), isFalse);
    driver.toggleOnlineStatus();
    expect(driver.incomingRequests, hasLength(1));
    final request = driver.incomingRequests.single;
    expect(request.isDemo, isTrue);
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
    expect(driver.addIncomingRequest(overlappingRequest), isFalse);
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

  test('going offline clears pending requests and rejects new ones', () {
    final driver = DriverProvider.instance;
    driver.resetSession();
    driver.toggleOnlineStatus();
    expect(driver.incomingRequests, hasLength(1));
    expect(driver.incomingRequests.single.isDemo, isTrue);

    driver.toggleOnlineStatus();

    expect(driver.incomingRequests, isEmpty);
    expect(
      driver.addIncomingRequest(
        Trip(
          id: 'OFFLINE-REQUEST',
          patientName: 'Test Patient',
          distanceKm: 2.0,
          requestedAt: DateTime.now(),
          pickup: 'Pickup',
          destination: 'Hospital',
          status: TripStatus.requested,
        ),
      ),
      isFalse,
    );
    driver.resetSession();
  });

  test('online driver can simulate another demo request', () {
    final driver = DriverProvider.instance;
    driver.resetSession();
    driver.toggleOnlineStatus();
    final initialRequest = driver.incomingRequests.single;

    driver.declineRequest(initialRequest);
    expect(driver.simulateDemoRequest(), isTrue);
    expect(driver.incomingRequests.single.isDemo, isTrue);

    driver.resetSession();
  });
}
