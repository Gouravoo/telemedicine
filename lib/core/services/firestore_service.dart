import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// ──────────────────────────────────────────────────────────────
/// FIRESTORE SERVICE — All database operations centralized
/// ──────────────────────────────────────────────────────────────
/// Currently uses mock data. Replace with actual Firestore calls.
/// Backend changes only happen HERE — UI code never touches Firestore.
/// ──────────────────────────────────────────────────────────────

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

class FirestoreService {
  // ─── DOCTORS ───

  /// Get all active doctors
  Future<List<DoctorModel>> getDoctors({
    String? specialty,
    String? searchQuery,
    String sortBy = 'rating',
  }) async {
    // TODO: Replace with Firestore query
    // var query = FirebaseFirestore.instance
    //     .collection('doctors')
    //     .where('isActive', isEqualTo: true);
    // if (specialty != null) query = query.where('specialty', isEqualTo: specialty);
    
    await Future.delayed(const Duration(milliseconds: 600));
    var doctors = List<DoctorModel>.from(_mockDoctors);

    if (specialty != null && specialty.isNotEmpty) {
      doctors = doctors.where((d) => d.specialty == specialty).toList();
    }
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
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockDoctors.firstWhere((d) => d.id == doctorId);
    } catch (_) {
      return null;
    }
  }

  /// Add a new doctor (Admin only)
  Future<void> addDoctor(DoctorModel doctor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockDoctors.add(doctor);
  }

  /// Update doctor profile
  Future<void> updateDoctor(DoctorModel doctor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _mockDoctors.indexWhere((d) => d.id == doctor.id);
    if (idx >= 0) _mockDoctors[idx] = doctor;
  }

  /// Soft-delete doctor
  Future<void> deleteDoctor(String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _mockDoctors.indexWhere((d) => d.id == doctorId);
    if (idx >= 0) {
      _mockDoctors[idx] = _mockDoctors[idx].copyWith(isActive: false);
    }
  }

  // ─── APPOINTMENTS ───

  /// Get appointments for a user (patient or doctor)
  Future<List<AppointmentModel>> getAppointments({
    String? patientId,
    String? doctorId,
    AppointmentStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var list = List<AppointmentModel>.from(_mockAppointments);

    if (patientId != null) {
      list = list.where((a) => a.patientId == patientId).toList();
    }
    if (doctorId != null) {
      list = list.where((a) => a.doctorId == doctorId).toList();
    }
    if (status != null) {
      list = list.where((a) => a.status == status).toList();
    }

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Get all appointments (Admin)
  Future<List<AppointmentModel>> getAllAppointments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<AppointmentModel>.from(_mockAppointments)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Create a new appointment
  Future<AppointmentModel> createAppointment(AppointmentModel appointment) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockAppointments.add(appointment);
    return appointment;
  }

  /// Update appointment status
  Future<void> updateAppointmentStatus(
      String appointmentId, AppointmentStatus status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _mockAppointments.indexWhere((a) => a.id == appointmentId);
    if (idx >= 0) {
      _mockAppointments[idx] = _mockAppointments[idx].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
    }
  }

  // ─── PATIENTS ───

  /// Get all patients (Admin)
  Future<List<PatientModel>> getAllPatients() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockPatients;
  }

  /// Save patient profile
  Future<void> savePatientProfile(PatientModel patient) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  // ─── HEALTH TIPS ───

  /// Get health tips
  Future<List<HealthTipModel>> getHealthTips() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockHealthTips;
  }

  /// Add health tip (Admin)
  Future<void> addHealthTip(HealthTipModel tip) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _mockHealthTips.add(tip);
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

  // ═══════════════════════════════════════════════════════════════
  // MOCK DATA — Remove when Firebase is connected
  // ═══════════════════════════════════════════════════════════════

  final List<DoctorModel> _mockDoctors = [
    DoctorModel(
      id: 'doc_1',
      name: 'Dr. Santosh Kumar Singh',
      email: 'santosh.singh@aarogyaplus.com',
      photoUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=2070&auto=format&fit=crop',
      specialty: 'Cardiologist',
      qualifications: 'MBBS, MD (Cardiology), FACC',
      experienceYears: 15,
      consultationFee: 1200,
      rating: 4.9,
      ratingCount: 320,
      bio: 'Renowned Cardiologist with 15+ years of experience in interventional cardiology, heart failure management, and preventive heart care.',
      isActive: true,
      availability: {
        'Monday': [
          const TimeSlot(startTime: '09:00', endTime: '09:30'),
          const TimeSlot(startTime: '09:30', endTime: '10:00'),
          const TimeSlot(startTime: '10:00', endTime: '10:30'),
          const TimeSlot(startTime: '14:00', endTime: '14:30'),
        ],
        'Tuesday': [
          const TimeSlot(startTime: '10:00', endTime: '10:30'),
          const TimeSlot(startTime: '11:00', endTime: '11:30'),
        ],
        'Wednesday': [
          const TimeSlot(startTime: '09:00', endTime: '09:30'),
          const TimeSlot(startTime: '15:30', endTime: '16:00'),
        ],
      },
    ),
    DoctorModel(
      id: 'doc_2',
      name: 'Dr. Neha Sharma',
      email: 'neha.sharma@aarogyaplus.com',
      photoUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?q=80&w=2070&auto=format&fit=crop',
      specialty: 'Dermatologist',
      qualifications: 'MBBS, MD (Dermatology)',
      experienceYears: 10,
      consultationFee: 800,
      rating: 4.8,
      ratingCount: 215,
      bio: 'Expert Dermatologist specializing in clinical and cosmetic dermatology. Extensive experience treating severe acne, eczema, and skin aging.',
      isActive: true,
      availability: {
        'Monday': [
          const TimeSlot(startTime: '11:00', endTime: '11:30'),
          const TimeSlot(startTime: '11:30', endTime: '12:00'),
        ],
        'Thursday': [
          const TimeSlot(startTime: '09:00', endTime: '09:30'),
          const TimeSlot(startTime: '14:00', endTime: '14:30'),
        ],
        'Friday': [
          const TimeSlot(startTime: '10:00', endTime: '10:30'),
          const TimeSlot(startTime: '10:30', endTime: '11:00'),
        ],
      },
    ),
  ];

  final List<AppointmentModel> _mockAppointments = [
    AppointmentModel(
      id: 'apt_1',
      patientId: 'google_mock_user',
      doctorId: 'doc_1',
      patientName: 'Rahul Sharma',
      doctorName: 'Dr. Priya Mehta',
      doctorSpecialty: 'Cardiologist',
      doctorPhotoUrl: 'https://ui-avatars.com/api/?name=Priya+Mehta&background=0F9D8C&color=fff&size=200',
      date: DateTime.now().add(const Duration(days: 2)),
      timeSlot: '09:00 - 09:30',
      status: AppointmentStatus.accepted,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
    AppointmentModel(
      id: 'apt_2',
      patientId: 'google_mock_user',
      doctorId: 'doc_3',
      patientName: 'Rahul Sharma',
      doctorName: 'Dr. Ananya Singh',
      doctorSpecialty: 'Dermatologist',
      doctorPhotoUrl: 'https://ui-avatars.com/api/?name=Ananya+Singh&background=2ECC71&color=fff&size=200',
      date: DateTime.now().add(const Duration(days: 5)),
      timeSlot: '10:00 - 10:30',
      status: AppointmentStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AppointmentModel(
      id: 'apt_3',
      patientId: 'google_mock_user',
      doctorId: 'doc_2',
      patientName: 'Rahul Sharma',
      doctorName: 'Dr. Rajesh Kumar',
      doctorSpecialty: 'General Physician',
      doctorPhotoUrl: 'https://ui-avatars.com/api/?name=Rajesh+Kumar&background=3D5AFE&color=fff&size=200',
      date: DateTime.now().subtract(const Duration(days: 3)),
      timeSlot: '14:00 - 14:30',
      status: AppointmentStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  final List<PatientModel> _mockPatients = [
    const PatientModel(uid: 'google_mock_user', age: 28, gender: 'Male', bloodGroup: 'O+'),
    const PatientModel(uid: 'patient_2', age: 35, gender: 'Female', bloodGroup: 'A+'),
    const PatientModel(uid: 'patient_3', age: 45, gender: 'Male', bloodGroup: 'B+'),
  ];

  final List<HealthTipModel> _mockHealthTips = [
    HealthTipModel(
      id: 'tip_1',
      title: 'Stay Hydrated This Summer',
      content: 'Drink at least 8-10 glasses of water daily. Dehydration can lead to headaches, fatigue, and reduced cognitive function. Add lemon or cucumber for a refreshing twist.',
      category: 'Wellness',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      createdBy: 'admin',
    ),
    HealthTipModel(
      id: 'tip_2',
      title: 'Importance of Regular Health Checkups',
      content: 'Annual health screenings can detect potential health issues early. Don\'t skip your routine blood tests, blood pressure checks, and eye exams.',
      category: 'Prevention',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      createdBy: 'admin',
    ),
    HealthTipModel(
      id: 'tip_3',
      title: 'Managing Stress with Mindfulness',
      content: 'Practice 10 minutes of meditation daily to reduce stress hormones. Deep breathing exercises and progressive muscle relaxation can significantly improve mental health.',
      category: 'Mental Health',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      createdBy: 'admin',
    ),
    HealthTipModel(
      id: 'tip_4',
      title: 'Heart-Healthy Diet Tips',
      content: 'Include omega-3 rich foods like fish, walnuts, and flaxseeds. Reduce sodium intake and choose whole grains over refined carbs for better cardiovascular health.',
      category: 'Nutrition',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      createdBy: 'admin',
    ),
  ];
}
