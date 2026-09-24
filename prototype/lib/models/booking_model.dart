class BookingModel {
  BookingModel({
    required this.id,
    required this.patientName,
    required this.emergencyType,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String patientName;
  final String emergencyType;
  final String status;
  final double latitude;
  final double longitude;
}
