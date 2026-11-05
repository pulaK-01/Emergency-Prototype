import 'package:medirapid/features/auth/models/driver_verification_status.dart';

abstract class DriverVerificationRepository {
  DriverVerificationStatus get status;
  Future<void> submitForReview();
  Future<void> approve();
  Future<void> reject();
  Future<void> reset();
}

class InMemoryDriverVerificationRepository
    implements DriverVerificationRepository {
  InMemoryDriverVerificationRepository();

  DriverVerificationStatus _status = DriverVerificationStatus.notStarted;

  @override
  DriverVerificationStatus get status => _status;

  @override
  Future<void> submitForReview() async {
    _status = DriverVerificationStatus.pending;
  }

  @override
  Future<void> approve() async {
    _status = DriverVerificationStatus.approved;
  }

  @override
  Future<void> reject() async {
    _status = DriverVerificationStatus.rejected;
  }

  @override
  Future<void> reset() async {
    _status = DriverVerificationStatus.notStarted;
  }
}
