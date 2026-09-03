

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const EmergencyApp());

class EmergencyApp extends StatelessWidget {
  const EmergencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Help',
      theme: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
      home: const EmergencyScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _isLoading = false;
  String _statusMessage = 'Tap the button for help';
  Position? _currentLocation;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  // Check location permission on app start
  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
  }

  // Main function: get exact location when button is pressed
  Future<void> _getExactLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Getting your exact location...';
      _errorMessage = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Please enable location services';
          _errorMessage = 'Location services are disabled';
        });
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _statusMessage = 'Location permission denied';
            _errorMessage = 'Cannot get your location without permission';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Location permission permanently denied';
          _errorMessage = 'Please enable in settings';
        });
        return;
      }

      // Get exact location with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = position;
        _isLoading = false;
        _statusMessage = '✅ Location obtained successfully!';

        // Format the coordinates for display
        String lat = position.latitude.toStringAsFixed(6);
        String lng = position.longitude.toStringAsFixed(6);

        _statusMessage = '✅ Location: $lat, $lng\nHelp is on the way!';
      });

      // Here you will send this location to your backend
      await _sendLocationToBackend(position);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _statusMessage = 'Error getting location';
      });
    }
  }

  // Send location to backend (to be implemented by your teammates)
  Future<void> _sendLocationToBackend(Position position) async {
    // TODO: Implement API endpoint to send:
    // - latitude: position.latitude
    // - longitude: position.longitude
    // - timestamp: DateTime.now()
    // - device info, etc.

    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency sent! Help is on the way.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emergency Button
                GestureDetector(
                  onTap: _isLoading ? null : _getExactLocation,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 5,
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emergency,
                                  size: 80,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'HELP',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 50),

                // Status Card
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
                          child: Column(
                            children: [
                              Text(
                                '📍 Exact Location',
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
