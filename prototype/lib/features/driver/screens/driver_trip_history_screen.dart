import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../providers/driver_provider.dart';
import '../repositories/trip_repository.dart';
import '../widgets/driver_page_scaffold.dart';

class DriverTripHistoryPage extends StatefulWidget {
  const DriverTripHistoryPage({super.key});

  @override
  State<DriverTripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<DriverTripHistoryPage> {
  final _driver = DriverProvider.instance;
  List<Trip> trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final loadedTrips = await getTrips();
    setState(() {
      trips = loadedTrips;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final date = dateTime.toLocal();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${date.year}-$month-$day  $hour:$minute';
  }

  /*  String _formatTime(DateTime dateTime) {
    final time = dateTime.toLocal();
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  } */

  void _showTripDialog(BuildContext context, Trip trip) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Trip ${trip.id}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Patient: ${trip.patientName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.brown,
              ),
            ),
          ],
        ),
        surfaceTintColor: Colors.blueAccent,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distance:${trip.distanceKm.toStringAsFixed(1)} km,',
              style: TextStyle(fontSize: 16, color: Colors.deepOrange[900]),
            ),
            const SizedBox(height: 5),
            Text(
              'Trip Status: ${trip.statusText}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Help Requested at: ${_formatDateTime(trip.requestedAt)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Pick up location: ${trip.pickup}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Drop off location: ${trip.destination}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            if (trip.completedAt != null)
              Text(
                'Trip ended at: ${_formatDateTime(trip.completedAt!)}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 5),
            Text(
              'Earnings from this trip: ${trip.fare == null ? '—' : '₹${trip.fare!.toStringAsFixed(2)}'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DriverPageScaffold(
      title: 'Trip History',
      selectedIndex: 2,
      body: AnimatedBuilder(
        animation: _driver,
        builder: (context, child) {
          final allTrips = [..._driver.completedTrips, ...trips];
          return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: allTrips.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 16);
        },
        itemBuilder: (context, index) {
          final trip = allTrips[index];

          return Card(
            elevation: 5,
            shadowColor: Colors.blueAccent,
            surfaceTintColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showTripDialog(context, trip),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatDateTime(trip.requestedAt),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            /* if (trip.status == TripStatus.completed &&
                                      trip.completedAt != null)
                                    Text(
                                      'Completed at: ${_formatTime(trip.completedAt!)}',
                                      style: const TextStyle(fontSize: 12),
                                    ), */
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: trip.statusBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            trip.statusText,
                            style: TextStyle(
                              color: trip.statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text('From: ${trip.pickup}')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.flag, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text('To: ${trip.destination}')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Earnings', style: TextStyle(fontSize: 16)),
                        Text(
                          trip.fare == null
                              ? '—'
                              : '₹${trip.fare!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
          );
        },
      ),
    );
  }
}
