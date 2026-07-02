import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/responsive_layout.dart';

/// Patient navigation shell — wraps all patient screens with nav
class PatientShell extends ConsumerWidget {
  final Widget child;

  const PatientShell({super.key, required this.child});

  static const _destinations = [
    NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
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
    '/patient/home',

    '/patient/appointments',
    '/patient/profile',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final currentIndex = _routes.indexWhere((r) => currentLocation.startsWith(r));

    return ResponsiveLayout(
      currentIndex: currentIndex < 0 ? 0 : currentIndex,
      onDestinationSelected: (index) => context.go(_routes[index]),
      destinations: _destinations,
      body: child,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.error,
        onPressed: () => _showEmergencyDialog(context),
        child: const Icon(Icons.emergency_outlined, color: Colors.white),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.emergency, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            const Text('Emergency'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Need immediate medical help?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.errorSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.phone, color: AppColors.error),
              ),
              title: const Text('Call Emergency Helpline'),
              subtitle: const Text('Dial 108'),
              onTap: () {
                Navigator.pop(context);
                // TODO: url_launcher to dial 108
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.video_call, color: AppColors.primary),
              ),
              title: const Text('Connect to On-Duty Doctor'),
              subtitle: const Text('Priority appointment'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Create priority appointment
              },
            ),
          ],
        ),
      ),
    );
  }
}
