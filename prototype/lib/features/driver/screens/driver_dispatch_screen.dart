import 'package:flutter/material.dart';
import 'package:medirapid/core/routes/app_routes.dart';
import 'package:medirapid/features/driver/models/trip_model.dart';
import 'package:medirapid/features/driver/providers/driver_provider.dart';
import 'package:medirapid/features/driver/widgets/driver_page_scaffold.dart';

class DriverDispatchScreen extends StatefulWidget {
  const DriverDispatchScreen({super.key});

  @override
  State<DriverDispatchScreen> createState() => _DriverDispatchScreenState();
}

class _DriverDispatchScreenState extends State<DriverDispatchScreen> {
  final _driver = DriverProvider.instance;

  @override
  void initState() {
    super.initState();
    _driver.addListener(_handleRequestsChanged);
    _startCountdownForCurrentRequest();
  }

  void _handleRequestsChanged() {
    _startCountdownForCurrentRequest();
  }

  void _startCountdownForCurrentRequest() {
    final requests = _driver.incomingRequests;
    final request = requests.isEmpty ? null : requests.first;
    if (request != null) _driver.startRequestCountdown(request);
  }

  void _acceptRequest(Trip trip) {
    if (_driver.acceptRequest(trip)) {
      Navigator.pushReplacementNamed(context, AppRoutes.driverCurrentTripFlow);
    }
  }

  void _declineRequest(Trip trip) {
    _driver.declineRequest(trip);
  }

  @override
  void dispose() {
    _driver.removeListener(_handleRequestsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DriverPageScaffold(
      title: 'Dispatch',
      selectedIndex: 1,
      body: AnimatedBuilder(
        animation: _driver,
        builder: (context, child) {
          if (_driver.isOnTrip) {
            return _DispatchTripInProgress(
              onReturnToTrip: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.driverCurrentTripFlow,
              ),
            );
          }

          final requests = _driver.incomingRequests;
          if (requests.isEmpty) {
            return _DispatchEmptyState(expired: _driver.lastRequestExpired);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDA1745),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'EMERGENCY BROADCAST',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent, width: 3),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_driver.requestSecondsRemaining}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'SECONDS',
                        style: TextStyle(fontSize: 10, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(child: Text('Accept before the request expires')),
              const SizedBox(height: 20),
              ...requests.map(
                (trip) => _RequestCard(
                  trip: trip,
                  onAccept: _driver.isOnTrip
                      ? null
                      : () => _acceptRequest(trip),
                  onDecline: () => _declineRequest(trip),
                  isDriverOnTrip: _driver.isOnTrip,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.trip,
    required this.onAccept,
    required this.onDecline,
    required this.isDriverOnTrip,
  });

  final Trip trip;
  final VoidCallback? onAccept;
  final VoidCallback onDecline;
  final bool isDriverOnTrip;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF14243E),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'INCIDENT TYPE',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              trip.incidentType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24, color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RequestDetail(
                  label: 'DISTANCE',
                  value: '${trip.distanceKm.toStringAsFixed(1)} km',
                  icon: Icons.navigation,
                ),
                _RequestDetail(
                  label: 'CASUALTIES',
                  value: '${trip.patientCount} patient',
                  icon: Icons.people_alt_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AddressLine(icon: Icons.location_on, text: trip.pickup),
            const SizedBox(height: 8),
            _AddressLine(icon: Icons.local_hospital, text: trip.destination),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAccept,
                icon: Icon(isDriverOnTrip ? Icons.lock_outline : Icons.check),
                label: Text(
                  isDriverOnTrip
                      ? 'Finish current trip first'
                      : 'Accept Request',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF078D60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: onDecline,
                child: const Text(
                  'Decline',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestDetail extends StatelessWidget {
  const _RequestDetail({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddressLine extends StatelessWidget {
  const _AddressLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _DispatchEmptyState extends StatelessWidget {
  const _DispatchEmptyState({required this.expired});

  final bool expired;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              expired ? Icons.timer_off_outlined : Icons.notifications_none,
              size: 56,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 16),
            Text(
              expired ? 'Request Expired' : 'No New Requests',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              expired
                  ? 'This request was assigned to another available responder.'
                  : 'New emergency requests will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _DispatchTripInProgress extends StatelessWidget {
  const _DispatchTripInProgress({required this.onReturnToTrip});

  final VoidCallback onReturnToTrip;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emergency, size: 56, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Trip in Progress',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'New booking requests are unavailable while you are on a trip.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onReturnToTrip,
              icon: const Icon(Icons.navigation),
              label: const Text('Return to Current Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
