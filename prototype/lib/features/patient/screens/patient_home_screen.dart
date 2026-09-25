import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  bool _isLoading = false;
  String _statusMessage =
      'Are you in emergency? press the button above and help will reach youshortly.';
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
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _statusMessage = 'Please enable location services';
          _errorMessage = 'Location services are disabled';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _statusMessage = 'Location permission denied';
          _errorMessage = 'Allow location access to send emergency help';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      ).timeout(const Duration(seconds: 25));

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
        title: const Text('Patient Emergency'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                          color: Colors.red.withValues(alpha: .6),
                          blurRadius: 20,
                          spreadRadius: 9,
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
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white,
                                        Colors.white,
                                        Color(0x805FEC2B),
                                      ],
                                      stops: [0.0, 0.58, 1.0],
                                    ).createShader(bounds);
                                  },
                                  child: const Icon(
                                    Icons.emergency,
                                    size: 130,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Color(0x805FEC2B),
                                        offset: Offset(0, 10),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'SOS',
                                  style: GoogleFonts.sora(
                                    fontSize: 42,
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
                              const Text(
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
