import 'dart:async';

import 'package:flutter/material.dart';

import '../models/trip_flow_model.dart';
import '../models/trip_model.dart';

class DriverProvider extends ChangeNotifier {
  bool isOnline = false;
  final List<Trip> _incomingRequests = [];
  final List<Trip> _completedTrips = [];
  Trip? _activeTrip;
  TripStage? _tripStage;
  DateTime? _tripStartedAt;
  bool _patientAssessed = false;
  bool _firstAidGiven = false;
  bool _patientLoaded = false;
  bool _lastRequestExpired = false;
  Timer? _requestTimer;
  DateTime? _requestDeadline;
  String? _countdownRequestId;
  int _requestSecondsRemaining = 30;
  int _demoRequestSequence = 1009;

  static final DriverProvider instance = DriverProvider._();

  DriverProvider._();

  List<Trip> get incomingRequests => List.unmodifiable(_incomingRequests);
  List<Trip> get completedTrips => List.unmodifiable(_completedTrips);
  Trip? get activeTrip => _activeTrip;
  TripStage? get tripStage => _tripStage;
  DateTime? get tripStartedAt => _tripStartedAt;
  bool get patientAssessed => _patientAssessed;
  bool get firstAidGiven => _firstAidGiven;
  bool get patientLoaded => _patientLoaded;
  bool get lastRequestExpired => _lastRequestExpired;
  int get requestSecondsRemaining => _requestSecondsRemaining;
  bool get isChecklistComplete =>
      _patientAssessed && _firstAidGiven && _patientLoaded;
  bool get isOnTrip => _activeTrip != null && _tripStage != TripStage.completed;
  double get todayEarnings => _completedTrips.fold<double>(
    0.0,
    (total, trip) => total + (trip.fare ?? 0.0),
  );

  bool addIncomingRequest(Trip trip) {
    if (!isOnline ||
        isOnTrip ||
        _incomingRequests.any((request) => request.id == trip.id)) {
      return false;
    }
    _incomingRequests.insert(0, trip);
    _lastRequestExpired = false;
    startRequestCountdown(trip);
    notifyListeners();
    return true;
  }

  bool simulateDemoRequest() {
    if (!isOnline || isOnTrip || _incomingRequests.isNotEmpty) return false;
    return addIncomingRequest(_createDemoRequest());
  }

  void startRequestCountdown(Trip trip) {
    if (_countdownRequestId == trip.id) return;
    _requestTimer?.cancel();
    _countdownRequestId = trip.id;
    _requestDeadline = DateTime.now().add(const Duration(seconds: 30));
    _requestSecondsRemaining = 30;
    _requestTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final deadline = _requestDeadline;
      if (deadline == null) {
        timer.cancel();
        return;
      }
      final remaining = deadline.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        timer.cancel();
        expireRequest(trip);
        return;
      }
      _requestSecondsRemaining = remaining;
      notifyListeners();
    });
  }

  bool acceptRequest(Trip trip) {
    if (!isOnline ||
        isOnTrip ||
        !_incomingRequests.any((request) => request.id == trip.id)) {
      return false;
    }
    _cancelRequestCountdown();
    _incomingRequests.clear();
    _activeTrip = trip;
    _tripStage = TripStage.navigatingToPickup;
    _tripStartedAt = DateTime.now();
    _patientAssessed = false;
    _firstAidGiven = false;
    _patientLoaded = false;
    _lastRequestExpired = false;
    notifyListeners();
    return true;
  }

  void declineRequest(Trip trip) {
    if (!_incomingRequests.any((request) => request.id == trip.id)) return;
    _cancelRequestCountdown();
    _incomingRequests.removeWhere((request) => request.id == trip.id);
    _lastRequestExpired = false;
    notifyListeners();
  }

  void expireRequest(Trip trip) {
    if (!_incomingRequests.any((request) => request.id == trip.id)) return;
    _cancelRequestCountdown();
    _incomingRequests.removeWhere((request) => request.id == trip.id);
    _lastRequestExpired = true;
    notifyListeners();
  }

  void markArrived() {
    if (_tripStage == TripStage.navigatingToPickup) {
      _setStage(TripStage.arrived);
    }
  }

  void beginAssessment() {
    if (_tripStage == TripStage.arrived) _setStage(TripStage.active);
  }

  void setPatientAssessed(bool value) {
    if (_tripStage != TripStage.active) return;
    _patientAssessed = value;
    notifyListeners();
  }

  void setFirstAidGiven(bool value) {
    if (_tripStage != TripStage.active) return;
    _firstAidGiven = value;
    notifyListeners();
  }

  void setPatientLoaded(bool value) {
    if (_tripStage != TripStage.active) return;
    _patientLoaded = value;
    notifyListeners();
  }

  void navigateToDestination() {
    if (_tripStage == TripStage.active && isChecklistComplete) {
      _setStage(TripStage.navigatingToDestination);
    }
  }

  void completeTrip() {
    final trip = _activeTrip;
    if (trip == null || _tripStage != TripStage.navigatingToDestination) return;

    final completedAt = DateTime.now();
    _completedTrips.insert(
      0,
      Trip(
        id: trip.id,
        patientName: trip.patientName,
        distanceKm: trip.distanceKm,
        requestedAt: trip.requestedAt,
        pickup: trip.pickup,
        destination: trip.destination,
        status: TripStatus.completed,
        completedAt: completedAt,
        fare: trip.distanceKm * 50,
        incidentType: trip.incidentType,
        patientCount: trip.patientCount,
        isDemo: trip.isDemo,
      ),
    );
    _setStage(TripStage.completed);
  }

  void clearCompletedTrip() {
    _activeTrip = null;
    _tripStage = null;
    _tripStartedAt = null;
    notifyListeners();
  }

  void resetSession() {
    _cancelRequestCountdown();
    _incomingRequests.clear();
    _completedTrips.clear();
    _activeTrip = null;
    _tripStage = null;
    _tripStartedAt = null;
    _patientAssessed = false;
    _firstAidGiven = false;
    _patientLoaded = false;
    _lastRequestExpired = false;
    isOnline = false;
    notifyListeners();
  }

  void toggleOnlineStatus() {
    if (isOnTrip) return;
    isOnline = !isOnline;
    if (isOnline) {
      simulateDemoRequest();
      return;
    }
    _cancelRequestCountdown();
    _incomingRequests.clear();
    _lastRequestExpired = false;
    notifyListeners();
  }

  void _setStage(TripStage stage) {
    _tripStage = stage;
    notifyListeners();
  }

  void _cancelRequestCountdown() {
    _requestTimer?.cancel();
    _requestTimer = null;
    _requestDeadline = null;
    _countdownRequestId = null;
  }

  Trip _createDemoRequest() {
    final requestNumber = _demoRequestSequence++;
    return Trip(
      id: 'DEMO-$requestNumber',
      requestedAt: DateTime.now(),
      pickup: 'Avenue 45, North Block',
      destination: 'City General Hospital',
      status: TripStatus.requested,
      patientName: 'Aarav Sharma',
      distanceKm: 4.2,
      incidentType: 'Road Accident',
      isDemo: true,
    );
  }
}
