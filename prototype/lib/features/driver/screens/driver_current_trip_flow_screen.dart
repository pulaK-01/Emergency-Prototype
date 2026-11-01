import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medirapid/core/routes/app_routes.dart';
import 'package:medirapid/features/driver/models/trip_flow_model.dart';
import 'package:medirapid/features/driver/models/trip_model.dart';
import 'package:medirapid/features/driver/providers/driver_provider.dart';

const _navy = Color(0xFF07152F);
const _panel = Color(0xFF122441);
const _green = Color(0xFF078D60);
const _blue = Color(0xFF1456D9);

class DriverCurrentTripFlowScreen extends StatefulWidget {
  const DriverCurrentTripFlowScreen({super.key});

  @override
  State<DriverCurrentTripFlowScreen> createState() =>
      _DriverCurrentTripFlowScreenState();
}

class _DriverCurrentTripFlowScreenState
    extends State<DriverCurrentTripFlowScreen> {
  final _driver = DriverProvider.instance;
  Timer? _elapsedTimer;

  @override
  void initState() {
    super.initState();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _driver.tripStage == TripStage.active) setState(() {});
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: const Text('Current Trip'),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _driver,
          builder: (context, child) {
            final trip = _driver.activeTrip;
            final stage = _driver.tripStage;
            final hasActiveTrip = trip != null && stage != null;
            return Column(
              children: [
                Expanded(
                  child: !hasActiveTrip
                      ? _NoActiveTrip(
                          onDispatch: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.driverDispatch,
                            );
                          },
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  16,
                                ),
                                children: [
                                  switch (stage) {
                                    TripStage.incoming || TripStage.expired =>
                                      _TripSummary(trip: trip),
                                    TripStage.navigatingToPickup =>
                                      _NavigationView(
                                        trip: trip,
                                        destination: trip.pickup,
                                        instruction: 'Turn left in 300 m',
                                        remainingDistance:
                                            '${trip.distanceKm} km',
                                      ),
                                    TripStage.arrived => _ArrivalView(
                                      trip: trip,
                                    ),
                                    TripStage.active => _ActiveTripView(
                                      trip: trip,
                                      elapsed: _elapsedTime(),
                                    ),
                                    TripStage.navigatingToDestination =>
                                      _NavigationView(
                                        trip: trip,
                                        destination: trip.destination,
                                        instruction: 'Continue to the hospital',
                                        remainingDistance:
                                            '${trip.distanceKm} km',
                                      ),
                                    TripStage.completed => _CompletedView(
                                      trip: trip,
                                      elapsed: _elapsedTime(),
                                    ),
                                  },
                                ],
                              ),
                            ),
                            _stageAction(context, trip, stage),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _stageAction(BuildContext context, Trip trip, TripStage stage) {
    switch (stage) {
      case TripStage.incoming:
      case TripStage.expired:
        return _BottomAction(
          label: 'Open Dispatch',
          icon: Icons.notifications_active_outlined,
          color: _blue,
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.driverDispatch),
        );
      case TripStage.navigatingToPickup:
        return _BottomAction(
          label: 'I have arrived',
          icon: Icons.check,
          color: _green,
          onPressed: _driver.markArrived,
        );
      case TripStage.arrived:
        return _BottomAction(
          label: 'Begin Assessment',
          icon: Icons.monitor_heart_outlined,
          color: _green,
          onPressed: _driver.beginAssessment,
        );
      case TripStage.active:
        return _BottomAction(
          label: 'Navigate to Destination',
          icon: Icons.navigation,
          color: _blue,
          onPressed: _driver.isChecklistComplete
              ? _driver.navigateToDestination
              : null,
        );
      case TripStage.navigatingToDestination:
        return _BottomAction(
          label: 'Arrived at Hospital · Complete Trip',
          icon: Icons.check_circle_outline,
          color: _blue,
          onPressed: _driver.completeTrip,
        );
      case TripStage.completed:
        return _BottomAction(
          label: 'Return to Dashboard',
          icon: Icons.home_outlined,
          color: _blue,
          onPressed: () {
            _driver.clearCompletedTrip();
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.driverHome,
              (route) => false,
            );
          },
        );
    }
  }

  String _elapsedTime() {
    final startedAt = _driver.tripStartedAt;
    if (startedAt == null) return '00:00';
    final elapsed = DateTime.now().difference(startedAt);
    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }
}

class _NavigationView extends StatelessWidget {
  const _NavigationView({
    required this.trip,
    required this.destination,
    required this.instruction,
    required this.remainingDistance,
  });

  final Trip trip;
  final String destination;
  final String instruction;
  final String remainingDistance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 330,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const CustomPaint(painter: _MapPainter()),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _navy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: _blue,
                          radius: 15,
                          child: Icon(
                            Icons.turn_left,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            instruction,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          remainingDistance,
                          style: const TextStyle(
                            color: Colors.lightGreenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Text(
                    'Navigating to $destination',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _IncidentCard(trip: trip),
      ],
    );
  }
}

class _ArrivalView extends StatelessWidget {
  const _ArrivalView({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 44),
        const Icon(Icons.location_on_outlined, color: _green, size: 64),
        const SizedBox(height: 14),
        const Text(
          'You Have Arrived',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Patient location confirmed via GPS',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 26),
        _IncidentCard(trip: trip),
        const SizedBox(height: 16),
        const _InfoBanner(
          icon: Icons.info_outline,
          text:
              'Please ensure safety precautions before exiting the vehicle to assess the patient.',
        ),
      ],
    );
  }
}

class _ActiveTripView extends StatelessWidget {
  const _ActiveTripView({required this.trip, required this.elapsed});

  final Trip trip;
  final String elapsed;

  @override
  Widget build(BuildContext context) {
    final driver = DriverProvider.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Active Trip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'IN PROGRESS',
                style: TextStyle(color: Colors.lightGreenAccent, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'ELAPSED TIME',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                elapsed,
                style: const TextStyle(
                  color: Colors.lightGreenAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _IncidentCard(trip: trip),
        const SizedBox(height: 18),
        const Text(
          'ON-SITE CHECKLIST',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _ChecklistTile(
          title: 'Patient assessed',
          value: driver.patientAssessed,
          onChanged: driver.setPatientAssessed,
        ),
        _ChecklistTile(
          title: 'First aid given',
          value: driver.firstAidGiven,
          onChanged: driver.setFirstAidGiven,
        ),
        _ChecklistTile(
          title: 'Loading patient',
          value: driver.patientLoaded,
          onChanged: driver.setPatientLoaded,
        ),
      ],
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(10),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (checked) => onChanged(checked ?? false),
        activeColor: _green,
        checkColor: Colors.white,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
      ),
    );
  }
}

class _CompletedView extends StatelessWidget {
  const _CompletedView({required this.trip, required this.elapsed});

  final Trip trip;
  final String elapsed;

  @override
  Widget build(BuildContext context) {
    final fare = trip.distanceKm * 50;
    return Column(
      children: [
        const SizedBox(height: 34),
        const Icon(Icons.check_circle_outline, color: _green, size: 64),
        const SizedBox(height: 14),
        const Text(
          'Trip Completed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'All tasks checked off successfully',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 26),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TRIP SUMMARY',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              _SummaryRow(label: 'Duration', value: elapsed),
              _SummaryRow(label: 'Distance', value: '${trip.distanceKm} km'),
              _SummaryRow(label: 'Emergency Type', value: trip.incidentType),
              _SummaryRow(
                label: 'Patient Count',
                value: '${trip.patientCount} Patient',
              ),
              _SummaryRow(
                label: 'Earnings',
                value: '₹${fare.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripSummary extends StatelessWidget {
  const _TripSummary({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) => _IncidentCard(trip: trip);
}

class _IncidentCard extends StatelessWidget {
  const _IncidentCard({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trip.incidentType,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${trip.patientCount} Patient',
                style: const TextStyle(color: Colors.redAccent, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.blueGrey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(trip.pickup, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          if (trip.destination.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.local_hospital_outlined,
                  size: 16,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    trip.destination,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _blue.withValues(alpha: 0.12),
        border: Border.all(color: _blue.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.lightBlueAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
            style: FilledButton.styleFrom(
              backgroundColor: color,
              disabledBackgroundColor: color.withValues(alpha: 0.35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoActiveTrip extends StatelessWidget {
  const _NoActiveTrip({required this.onDispatch});

  final VoidCallback onDispatch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.route, color: Colors.white54, size: 56),
            const SizedBox(height: 12),
            const Text(
              'No active trip',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onDispatch,
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('View Dispatch'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFF2C3748);
    canvas.drawRect(Offset.zero & size, background);

    final road = Paint()
      ..color = const Color(0xFF536174)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    final thinRoad = Paint()
      ..color = const Color(0xFF465366)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (final points in [
      [Offset(0, size.height * .22), Offset(size.width, size.height * .68)],
      [Offset(size.width * .12, 0), Offset(size.width * .32, size.height)],
      [
        Offset(size.width * .55, 0),
        Offset(size.width * .38, size.height * .62),
      ],
      [Offset(0, size.height * .82), Offset(size.width, size.height * .4)],
      [Offset(size.width * .78, 0), Offset(size.width * .7, size.height)],
    ]) {
      canvas.drawLine(points[0], points[1], road);
    }
    canvas.drawLine(
      Offset(size.width * .2, size.height * .84),
      Offset(size.width * .65, size.height * .48),
      thinRoad,
    );

    final route = Paint()
      ..color = _blue
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final routePath = Path()
      ..moveTo(size.width * .2, size.height * .92)
      ..lineTo(size.width * .28, size.height * .54)
      ..lineTo(size.width * .45, size.height * .49)
      ..lineTo(size.width * .68, size.height * .28);
    canvas.drawPath(routePath, route);

    final marker = Paint()..color = Colors.lightBlueAccent;
    canvas.drawCircle(Offset(size.width * .28, size.height * .54), 7, marker);
    canvas.drawCircle(
      Offset(size.width * .28, size.height * .54),
      12,
      Paint()
        ..color = Colors.lightBlueAccent.withValues(alpha: .3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(size.width * .68, size.height * .28),
      6,
      Paint()..color = Colors.redAccent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
