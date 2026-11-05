import 'package:flutter/material.dart';
import 'package:medirapid/core/routes/app_routes.dart';
import 'package:medirapid/features/auth/models/driver_verification_status.dart';
import 'package:medirapid/features/auth/repositories/driver_verification_repository.dart';

class DriverVerificationProvider extends ChangeNotifier {
  DriverVerificationProvider._({
    DriverVerificationRepository? repository,
  }) : _repository = repository ?? InMemoryDriverVerificationRepository();

  static final DriverVerificationProvider instance =
      DriverVerificationProvider._();

  final DriverVerificationRepository _repository;

  DriverVerificationStatus get status {
    if (AppRoutes.driverVerificationApproved) {
      return DriverVerificationStatus.approved;
    }
    return _repository.status;
  }

  bool get isApproved => status == DriverVerificationStatus.approved;
  bool get isPending => status == DriverVerificationStatus.pending;

  Future<void> submitForReview() async {
    AppRoutes.markDriverVerificationPending();
    await _repository.submitForReview();
    notifyListeners();
  }

  Future<void> approveVerification() async {
    AppRoutes.approveDriverVerification();
    await _repository.approve();
    notifyListeners();
  }

  Future<void> resetVerification() async {
    AppRoutes.markDriverVerificationPending();
    await _repository.reset();
    notifyListeners();
  }
}
