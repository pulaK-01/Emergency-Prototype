class TripModel {
  TripModel({
    required this.id,
    required this.patientName,
    required this.driverName,
    required this.status,
    required this.distanceKm,
  });

  final String id;
  final String patientName;
  final String driverName;
  final String status;
  final double distanceKm;
}
