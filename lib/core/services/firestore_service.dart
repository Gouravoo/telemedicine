import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// ──────────────────────────────────────────────────────────────
/// FIRESTORE SERVICE — All database operations centralized
/// ──────────────────────────────────────────────────────────────
/// Uses FirebaseFirestore.instance for real data.
/// ──────────────────────────────────────────────────────────────

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── DOCTORS ───

  /// Get all active doctors
  Future<List<DoctorModel>> getDoctors({
    String? specialty,
    String? searchQuery,
    String sortBy = 'rating',
  }) async {
    Query query = _db.collection('doctors').where('isActive', isEqualTo: true);

    if (specialty != null && specialty.isNotEmpty) {
      query = query.where('specialty', isEqualTo: specialty);
    }

    final snapshot = await query.get();
    var doctors = snapshot.docs
        .map((doc) => DoctorModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      doctors = doctors
          .where((d) =>
              d.name.toLowerCase().contains(q) ||
              d.specialty.toLowerCase().contains(q))
          .toList();
    }

    switch (sortBy) {
      case 'rating':
        doctors.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'experience':
        doctors.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
        break;
      case 'fee_low':
        doctors.sort((a, b) => a.consultationFee.compareTo(b.consultationFee));
        break;
      case 'fee_high':
        doctors.sort((a, b) => b.consultationFee.compareTo(a.consultationFee));
        break;
    }

    return doctors;
  }

  /// Get a single doctor by ID
  Future<DoctorModel?> getDoctor(String doctorId) async {
    final doc = await _db.collection('doctors').doc(doctorId).get();
    if (doc.exists) {
      return DoctorModel.fromJson(doc.data()!);
    }
    return null;
  }

  /// Add a new doctor (Admin only)
  Future<void> addDoctor(DoctorModel doctor) async {
    await _db.collection('doctors').doc(doctor.id).set(doctor.toJson());
  }

  /// Update doctor profile
  Future<void> updateDoctor(DoctorModel doctor) async {
    await _db.collection('doctors').doc(doctor.id).update(doctor.toJson());
  }

  /// Soft-delete doctor
  Future<void> deleteDoctor(String doctorId) async {
    await _db.collection('doctors').doc(doctorId).update({'isActive': false});
  }

  // ─── APPOINTMENTS ───

  /// Get appointments for a user (patient or doctor)
  Future<List<AppointmentModel>> getAppointments({
    String? patientId,
    String? doctorId,
    AppointmentStatus? status,
  }) async {
    Query query = _db.collection('appointments');

    if (patientId != null) {
      query = query.where('patientId', isEqualTo: patientId);
    }
    if (doctorId != null) {
      query = query.where('doctorId', isEqualTo: doctorId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    final snapshot = await query.get();
    var list = snapshot.docs
        .map((doc) => AppointmentModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Get all appointments (Admin)
  Future<List<AppointmentModel>> getAllAppointments() async {
    final snapshot = await _db.collection('appointments').get();
    var list = snapshot.docs
        .map((doc) => AppointmentModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Create a new appointment
  Future<AppointmentModel> createAppointment(AppointmentModel appointment) async {
    // Generate an ID if it's empty or keep existing
    final docRef = _db.collection('appointments').doc(appointment.id);
    final appointmentToSave = appointment.copyWith(id: docRef.id);
    await docRef.set(appointmentToSave.toJson());
    return appointmentToSave;
  }

  /// Update appointment status
  Future<void> updateAppointmentStatus(
      String appointmentId, AppointmentStatus status) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // ─── PATIENTS ───

  /// Get all patients (Admin)
  Future<List<PatientModel>> getAllPatients() async {
    // This fetches all users with role patient from users collection
    // Wait, PatientModel is different. We should fetch from users and map.
    // Or just fetch all from `users` collection where role is 'patient'.
    final snapshot = await _db.collection('users').where('role', isEqualTo: 'patient').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PatientModel(
        uid: data['uid'] ?? doc.id,
        age: 0, // Age not in user model directly right now
        gender: 'Not specified',
        bloodGroup: 'Not specified',
      );
    }).toList();
  }

  /// Save patient profile details
  Future<void> savePatientProfile(PatientModel patient) async {
    await _db.collection('patient_profiles').doc(patient.uid).set({
      'uid': patient.uid,
      'age': patient.age,
      'gender': patient.gender,
      'bloodGroup': patient.bloodGroup,
    });
  }

  // ─── HEALTH TIPS ───

  /// Get health tips
  Future<List<HealthTipModel>> getHealthTips() async {
    final snapshot = await _db.collection('health_tips').get();
    return snapshot.docs
        .map((doc) => HealthTipModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Add health tip (Admin)
  Future<void> addHealthTip(HealthTipModel tip) async {
    final docRef = _db.collection('health_tips').doc(tip.id);
    final tipToSave = tip.copyWith(id: docRef.id);
    await docRef.set(tipToSave.toJson());
  }

  // ─── SPECIALTIES ───

  List<String> getSpecialties() {
    return [
      'General Physician',
      'Cardiologist',
      'Dermatologist',
      'Orthopedic',
      'Pediatrician',
      'Neurologist',
      'Gynecologist',
      'ENT Specialist',
      'Ophthalmologist',
      'Psychiatrist',
      'Dentist',
      'Urologist',
    ];
  }
}
