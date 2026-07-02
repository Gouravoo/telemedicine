import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/models/models.dart';
import '../core/providers/app_providers.dart';

// Feature screens — Auth
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';

// Feature screens — Patient
import '../features/patient/patient_shell.dart';
import '../features/patient/home/screens/patient_home_screen.dart';
import '../features/patient/doctor_list/screens/doctor_list_screen.dart';
import '../features/patient/doctor_profile/screens/doctor_profile_screen.dart';
import '../features/patient/booking/screens/booking_screen.dart';
import '../features/patient/appointments/screens/patient_appointments_screen.dart';
import '../features/patient/profile/screens/patient_profile_screen.dart';

// Feature screens — Doctor
import '../features/doctor/doctor_shell.dart';
import '../features/doctor/dashboard/screens/doctor_dashboard_screen.dart';
import '../features/doctor/appointments/screens/doctor_appointments_screen.dart';
import '../features/doctor/profile/screens/doctor_profile_settings_screen.dart';

// Feature screens — Shared
import '../features/shared/video_call/screens/video_call_screen.dart';

// Feature screens — Admin
import '../features/admin/admin_shell.dart';
import '../features/admin/dashboard/screens/admin_dashboard_screen.dart';
import '../features/admin/doctors/screens/admin_doctors_screen.dart';
import '../features/admin/patients/screens/admin_patients_screen.dart';
import '../features/admin/appointments/screens/admin_appointments_screen.dart';
import '../features/admin/health_tips/screens/admin_health_tips_screen.dart';

/// App router provider with role-based routing
final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final loggedIn = user != null;
      final isAuthRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Not logged in, trying to access protected route
      if (!loggedIn && !isAuthRoute) {
        return '/login';
      }

      // Logged in, on auth route → redirect to role dashboard
      if (loggedIn && isAuthRoute) {
        switch (user.role) {
          case UserRole.patient:
            return '/patient/home';
          case UserRole.doctor:
            return '/doctor/dashboard';
          case UserRole.admin:
            return '/admin/dashboard';
        }
      }

      return null;
    },
    routes: [
      // ─── Auth Routes ───
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ─── Patient Routes ───
      ShellRoute(
        builder: (context, state, child) => PatientShell(child: child),
        routes: [
          GoRoute(
            path: '/patient/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PatientHomeScreen(),
            ),
          ),
          GoRoute(
            path: '/patient/doctors',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DoctorListScreen(),
            ),
          ),
          GoRoute(
            path: '/patient/appointments',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PatientAppointmentsScreen(),
            ),
          ),
          GoRoute(
            path: '/patient/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PatientProfileScreen(),
            ),
          ),
        ],
      ),

      // Patient non-shell routes (full-screen)
      GoRoute(
        path: '/patient/doctor/:doctorId',
        builder: (context, state) => DoctorProfileScreen(
          doctorId: state.pathParameters['doctorId']!,
        ),
      ),
      GoRoute(
        path: '/patient/book/:doctorId',
        builder: (context, state) => BookingScreen(
          doctorId: state.pathParameters['doctorId']!,
        ),
      ),

      // Video call route (shared by patient and doctor)
      GoRoute(
        path: '/call/:channelName',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return VideoCallScreen(
            channelName: state.pathParameters['channelName']!,
            callerName: extra['callerName'] ?? 'You',
            calleeName: extra['calleeName'] ?? 'Participant',
            isDoctor: extra['isDoctor'] ?? false,
          );
        },
      ),

      // ─── Doctor Routes ───
      ShellRoute(
        builder: (context, state, child) => DoctorShell(child: child),
        routes: [
          GoRoute(
            path: '/doctor/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DoctorDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/doctor/appointments',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DoctorAppointmentsScreen(),
            ),
          ),
          GoRoute(
            path: '/doctor/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DoctorProfileSettingsScreen(),
            ),
          ),
        ],
      ),

      // ─── Admin Routes ───
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/doctors',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminDoctorsScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/patients',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminPatientsScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/appointments',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminAppointmentsScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/health-tips',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminHealthTipsScreen(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
