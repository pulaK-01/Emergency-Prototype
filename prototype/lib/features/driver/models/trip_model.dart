import 'package:flutter/material.dart';

enum TripStatus { requested, inProgress, completed, cancelled }

class Trip {
  final String id;
  final String patientName;
  final double distanceKm;
  final DateTime requestedAt;
  final String pickup;
  final String destination;
  final TripStatus status;
  final DateTime? completedAt;
  final double? fare;
  final String incidentType;
  final int patientCount;

  const Trip({
    required this.id,
    required this.patientName,
    required this.distanceKm,
    required this.requestedAt,
    required this.pickup,
    required this.destination,
    required this.status,
    this.completedAt,
    this.fare,
    this.incidentType = 'Medical Emergency',
    this.patientCount = 1,
  });

  bool get isCompleted => status == TripStatus.completed;

  String get statusText {
    switch (status) {
      case TripStatus.requested:
        return 'Requested';
      case TripStatus.inProgress:
        return 'In Progress';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case TripStatus.requested:
      case TripStatus.inProgress:
        return Colors.orange;
      case TripStatus.completed:
        return Colors.green;
      case TripStatus.cancelled:
        return Colors.red;
    }
  }

  Color get statusBackgroundColor {
    switch (status) {
      case TripStatus.requested:
      case TripStatus.inProgress:
        return Colors.orange.shade100;
      case TripStatus.completed:
        return Colors.green.shade100;
      case TripStatus.cancelled:
        return Colors.red.shade100;
    }
  }
}



