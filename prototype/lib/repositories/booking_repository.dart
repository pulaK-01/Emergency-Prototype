import 'package:emergency_prototype/models/booking_model.dart';

class BookingRepository {
  Future<List<BookingModel>> getBookings() async {
    return [
      BookingModel(
        id: 'B001',
        patientName: 'Rahul',
        emergencyType: 'Medical',
        status: 'Waiting',
        latitude: 22.5726,
        longitude: 88.3639,
      ),
      BookingModel(
        id: 'B002',
        patientName: 'Nipa',
        emergencyType: 'Accident',
        status: 'Accepted',
        latitude: 22.575,
        longitude: 88.369,
      ),
    ];
  }
}
