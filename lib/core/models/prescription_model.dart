/// Individual medicine in a prescription
class Medicine {
  final String name;
  final String dosage;
  final String duration;
  final String? notes;

  const Medicine({
    required this.name,
    required this.dosage,
    required this.duration,
    this.notes,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      duration: json['duration'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'dosage': dosage,
        'duration': duration,
        'notes': notes,
      };
}

/// Prescription model stored in Firestore `prescriptions` collection
class PrescriptionModel {
  final String id;
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final List<Medicine> medicines;
  final String? fileUrl;
  final String? diagnosis;
  final String? notes;
  final DateTime createdAt;

  const PrescriptionModel({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    this.medicines = const [],
    this.fileUrl,
    this.diagnosis,
    this.notes,
    required this.createdAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      doctorId: json['doctorId'] as String,
      patientId: json['patientId'] as String,
      medicines: (json['medicines'] as List<dynamic>?)
              ?.map((m) => Medicine.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      fileUrl: json['fileUrl'] as String?,
      diagnosis: json['diagnosis'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'appointmentId': appointmentId,
        'doctorId': doctorId,
        'patientId': patientId,
        'medicines': medicines.map((m) => m.toJson()).toList(),
        'fileUrl': fileUrl,
        'diagnosis': diagnosis,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };
}
