import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/responsive_layout.dart';

/// Admin navigation shell
class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  static const _destinations = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    NavigationItem(
      icon: Icons.medical_services_outlined,
      selectedIcon: Icons.medical_services_rounded,
      label: 'Doctors',
    ),
    NavigationItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people_rounded,
      label: 'Patients',
    ),
    NavigationItem(
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today_rounded,
      label: 'Appointments',
    ),
    NavigationItem(
      icon: Icons.lightbulb_outline,
      selectedIcon: Icons.lightbulb_rounded,
      label: 'Health Tips',
    ),
  ];

  static const _routes = [
    '/admin/dashboard',
    '/admin/doctors',
    '/admin/patients',
    '/admin/appointments',
    '/admin/health-tips',
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
