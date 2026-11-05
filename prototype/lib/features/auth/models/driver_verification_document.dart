import 'package:flutter/material.dart';

enum DriverVerificationDocument {
  drivingLicence(
    title: 'Driving licence',
    subtitle: 'A valid licence for ambulance driving',
    icon: Icons.badge_outlined,
  ),
  vehicleRegistration(
    title: 'Vehicle registration certificate',
    subtitle: 'Registration for the ambulance vehicle',
    icon: Icons.airport_shuttle_outlined,
  ),
  vehicleInsurance(
    title: 'Vehicle insurance',
    subtitle: 'Current insurance document',
    icon: Icons.shield_outlined,
  ),
  ambulancePermit(
    title: 'Ambulance permit / fitness certificate',
    subtitle: 'Valid permit or fitness certification',
    icon: Icons.health_and_safety_outlined,
  );

  const DriverVerificationDocument({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
