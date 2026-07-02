import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';

/// ──────────────────────────────────────────────────────────────
/// RIVERPOD PROVIDERS — Dependency injection layer
/// ──────────────────────────────────────────────────────────────
/// UI reads data from providers. Providers call services.
/// Services talk to Firebase. Clean separation.
/// ──────────────────────────────────────────────────────────────

// ─── AUTH STATE ───

final currentUserProvider = StateProvider<UserModel?>((ref) => null);

final isLoadingProvider = StateProvider<bool>((ref) => false);

// ─── DOCTOR PROVIDERS ───

final doctorListProvider = FutureProvider.family<List<DoctorModel>, DoctorFilter>(
  (ref, filter) async {
    final service = ref.read(firestoreServiceProvider);
    return service.getDoctors(
      specialty: filter.specialty,
      searchQuery: filter.searchQuery,
      sortBy: filter.sortBy,
    );
  },
);

final doctorDetailProvider = FutureProvider.family<DoctorModel?, String>(
  (ref, doctorId) async {
    final service = ref.read(firestoreServiceProvider);
    return service.getDoctor(doctorId);
  },
);

final specialtiesProvider = Provider<List<String>>((ref) {
  final service = ref.read(firestoreServiceProvider);
  return service.getSpecialties();
});

// ─── APPOINTMENT PROVIDERS ───

final patientAppointmentsProvider =
    FutureProvider.family<List<AppointmentModel>, String>(
  (ref, patientId) async {
    final service = ref.read(firestoreServiceProvider);
    return service.getAppointments(patientId: patientId);
  },
);

final doctorAppointmentsProvider =
    FutureProvider.family<List<AppointmentModel>, String>(
  (ref, doctorId) async {
    final service = ref.read(firestoreServiceProvider);
    return service.getAppointments(doctorId: doctorId);
  },
);

final allAppointmentsProvider = FutureProvider<List<AppointmentModel>>(
  (ref) async {
    final service = ref.read(firestoreServiceProvider);
    return service.getAllAppointments();
  },
);

// ─── PATIENT PROVIDERS ───

final allPatientsProvider = FutureProvider<List<PatientModel>>(
  (ref) async {
    final service = ref.read(firestoreServiceProvider);
    return service.getAllPatients();
  },
);

// ─── HEALTH TIPS ───

final healthTipsProvider = FutureProvider<List<HealthTipModel>>(
  (ref) async {
    final service = ref.read(firestoreServiceProvider);
    return service.getHealthTips();
  },
);

// ─── FILTER MODEL ───

class DoctorFilter {
  final String? specialty;
  final String? searchQuery;
  final String sortBy;

  const DoctorFilter({
    this.specialty,
    this.searchQuery,
    this.sortBy = 'rating',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorFilter &&
          specialty == other.specialty &&
          searchQuery == other.searchQuery &&
          sortBy == other.sortBy;

  @override
  int get hashCode => Object.hash(specialty, searchQuery, sortBy);
}

// ─── SELECTED TAB PROVIDERS ───

final selectedNavIndexProvider = StateProvider<int>((ref) => 0);
final selectedAppointmentTabProvider = StateProvider<int>((ref) => 0);
