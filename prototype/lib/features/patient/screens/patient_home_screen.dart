import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medirapid/core/routes/app_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:medirapid/features/patient/widgets/emergency_button.dart';
import 'package:medirapid/services/location_service.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final LocationService _locationService = LocationService();

  bool _isLoading = false;
  String _statusMessage =
      'Press the button above and help will reach you shortly.';
  Position? _currentLocation;
  String? _errorMessage;

  Future<void> _getExactLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Getting your exact location...';
      _errorMessage = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _currentLocation = position;
        _isLoading = false;
        _statusMessage =
            '✅ Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}\nHelp is on the way!';
      });

      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Emergency sent! Help is on the way.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } on LocationServiceException catch (e) {
      if (!mounted) return;
      final (statusMessage, errorMessage) = switch (e.failure) {
        LocationFailure.servicesDisabled => (
          'Please enable location services',
          'Location services are disabled',
        ),
        LocationFailure.permissionDenied => (
          'Location permission denied',
          'Allow location access to send emergency help',
        ),
        LocationFailure.permissionPermanentlyDenied => (
          'Location permission permanently denied',
          'Enable location access in your device settings',
        ),
      };
      setState(() {
        _isLoading = false;
        _errorMessage = errorMessage;
        _statusMessage = statusMessage;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not get a GPS fix in time';
        _statusMessage = 'Move outdoors or near a window and try again';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _statusMessage = 'Error getting location';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency SOS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.patientSettings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Column(
                  children: [
                    Text(
                      'Are you in emergency?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      "Press the 'SOS' button below",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                EmergencyButton(
                  onPressed: _getExactLocation,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _errorMessage != null
                        ? Colors.red[50]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _errorMessage != null
                          ? Colors.red
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _errorMessage != null
                            ? Icons.error_outline
                            : _currentLocation != null
                            ? Icons.check_circle
                            : Icons.location_on,
                        size: 40,
                        color: _errorMessage != null
                            ? Colors.red
                            : _currentLocation != null
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _errorMessage != null
                              ? Colors.red
                              : Colors.black87,
                        ),
                      ),
                      if (_currentLocation != null) ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                const Text(
                                  '📍Exact Location',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 5),
                                Text(
                                  'Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Lng: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Accuracy: ${_currentLocation!.accuracy.toStringAsFixed(0)}m',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
