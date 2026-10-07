import 'package:flutter/material.dart';
import 'package:medirapid/core/routes/app_routes.dart';
import 'package:medirapid/features/driver/models/trip_model.dart';
import 'package:medirapid/features/driver/providers/driver_provider.dart';
import 'package:medirapid/features/driver/widgets/driver_page_scaffold.dart';
import 'package:medirapid/features/driver/models/trip_flow_model.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driver = DriverProvider.instance;
    return DriverPageScaffold(
      title: 'Driver Dashboard',
      actions: IconButton(
        tooltip: 'Profile',
        icon: const Icon(Icons.person),
        onPressed: () {
          Navigator.pushReplacementNamed(context, AppRoutes.driverProfile);
        },
      ),
      selectedIndex: 0,
      body: AnimatedBuilder(
        animation: driver,
        builder: (context, child) {
          final activeTrip = driver.activeTrip;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Good ${_greeting()}, Driver',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _AvailabilityCard(driver: driver),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Current trip',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (activeTrip != null)
                    Text(
                      'TRIP ${activeTrip.id}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (activeTrip == null)
                const _NoActiveTripCard()
              else
                _ActiveTripCard(
                  trip: activeTrip,
                  stage: driver.tripStage,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.driverCurrentTripFlow,
                  ),
                ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEAF2FF),
                    child: Icon(Icons.payments_outlined, color: Colors.blue),
                  ),
                  title: const Text('Today’s earnings'),
                  subtitle: const Text('From completed trips'),
                  trailing: Text(
                    '₹${driver.todayEarnings.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.driver});

  final DriverProvider driver;

  @override
  Widget build(BuildContext context) {
    final isOnTrip = driver.isOnTrip;
    final statusColor = isOnTrip
        ? Colors.orange
        : driver.isOnline
        ? Colors.green
        : Colors.blueGrey;
    final statusText = isOnTrip
        ? 'In trip'
        : driver.isOnline
        ? 'Available for requests'
        : 'Offline';

    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.12),
              child: Icon(
                isOnTrip
                    ? Icons.emergency
                    : driver.isOnline
                    ? Icons.wifi
                    : Icons.wifi_off,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current status',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (!isOnTrip)
              Switch(
                value: driver.isOnline,
                onChanged: (_) => driver.toggleOnlineStatus(),
                activeThumbColor: Colors.green,
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.lock_outline, color: Colors.orange),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  const _ActiveTripCard({
    required this.trip,
    required this.stage,
    required this.onTap,
  });

  final Trip trip;
  final TripStage? stage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.indigo,
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5EE),
                    child: Icon(Icons.route, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _stageTitle(stage),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pickup: ${trip.pickup}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.navigation),
                  label: const Text('Continue trip'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _stageTitle(TripStage? stage) => switch (stage) {
    TripStage.navigatingToPickup => 'Heading to pickup',
    TripStage.arrived => 'Arrived at pickup',
    TripStage.active => 'Patient care in progress',
    TripStage.navigatingToDestination => 'Heading to destination',
    TripStage.completed => 'Trip completed',
    _ => 'Trip in progress',
  };
}

class _NoActiveTripCard extends StatelessWidget {
  const _NoActiveTripCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFF1F3F5),
              child: Icon(Icons.route_outlined, color: Colors.blueGrey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No active trip',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
