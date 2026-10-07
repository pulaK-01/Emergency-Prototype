import 'package:flutter/material.dart';
import 'package:medirapid/core/routes/app_routes.dart';
import 'package:medirapid/features/driver/providers/driver_provider.dart';

import 'driver_request_banner.dart';

class DriverPageScaffold extends StatelessWidget {
  const DriverPageScaffold({
    required this.title,
    this.selectedIndex,
    required this.body,
    this.actions,
    this.backRoute,
    this.showBottomNavigationBar = true,
    super.key,
  });

  final String title;
  final int? selectedIndex;
  final Widget body;
  final Widget? actions;
  final String? backRoute;
  final bool showBottomNavigationBar;

  static const _routes = [
    AppRoutes.driverHome,
    AppRoutes.driverDispatch,
    AppRoutes.driverTripHistory,
  ];

  @override
  Widget build(BuildContext context) {
    final driver = DriverProvider.instance;
    return AnimatedBuilder(
      animation: driver,
      builder: (context, child) {
        final requestCount = driver.isOnTrip ? 0 : driver.incomingRequests.length;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            leading: backRoute == null
                ? null
                : IconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, backRoute!);
                    },
                  ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            actions: actions != null ? [actions!] : null,
          ),
          body: Column(
            children: [
              if (requestCount > 0)
                DriverRequestBanner(
                  requestCount: requestCount,
                  onTap: () {
                    if (selectedIndex != 1) {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.driverDispatch,
                      );
                    }
                  },
                ),
              Expanded(child: body),
            ],
          ),
          bottomNavigationBar: showBottomNavigationBar
              ? BottomNavigationBar(
            currentIndex: selectedIndex ?? 0,
            onTap: (index) {
              if (index != selectedIndex) {
                Navigator.pushReplacementNamed(context, _routes[index]);
              }
            },
            iconSize: 24,
            backgroundColor: Colors.blueAccent,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _DispatchNavIcon(count: requestCount),
                label: 'Dispatch',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
            ],
          )
              : null,
        );
      },
    );
  }
}

class _DispatchNavIcon extends StatelessWidget {
  const _DispatchNavIcon({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_active),
        if (count > 0)
          Positioned(
            right: -9,
            top: -7,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: Color(0xFFDA1745),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
