class AppRoutes {
  static const String roleSelection = '/';
  static const String patientHome = '/patient-home';
  static const String patientSettings = '/patient-settings';
  static const String driverVerification = '/driver-verification';
  static const String driverVerificationPending =
      '/driver-verification-pending';
  static const String driverHome = '/driver-home';
  static const String driverDispatch = '/driver-dispatch';
  static const String driverCurrentTripFlow = '/driver-current-trip-flow';
  static const String driverTripHistory = '/driver-trip-history';

  static const String driverSettings = '/driver-settings';
  static const String driverProfile = '/driver-profile';

  static bool _driverVerificationApproved = false;

  static bool get driverVerificationApproved => _driverVerificationApproved;

  static void markDriverVerificationPending() {
    _driverVerificationApproved = false;
  }

  static void approveDriverVerification() {
    _driverVerificationApproved = true;
  }
}
