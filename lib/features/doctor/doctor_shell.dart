import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/responsive_layout.dart';

/// Doctor navigation shell
class DoctorShell extends ConsumerWidget {
  final Widget child;
  const DoctorShell({super.key, required this.child});

  static const _destinations = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    NavigationItem(
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today_rounded,
      label: 'Appointments',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  static const _routes = [
    '/doctor/dashboard',
    '/doctor/appointments',
    '/doctor/profile',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final currentIndex =
        _routes.indexWhere((r) => currentLocation.startsWith(r));

    return ResponsiveLayout(
      currentIndex: currentIndex < 0 ? 0 : currentIndex,
      onDestinationSelected: (index) => context.go(_routes[index]),
      destinations: _destinations,
      body: child,
    );
  }
}
