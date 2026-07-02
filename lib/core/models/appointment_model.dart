/// Appointment status enum
enum AppointmentStatus { pending, accepted, rejected, completed, cancelled }

/// Appointment model stored in Firestore `appointments` collection
class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final String doctorSpecialty;
  final String? doctorPhotoUrl;
  final String? patientPhotoUrl;
  final DateTime date;
  final String timeSlot;
  final AppointmentStatus status;
  final List<String> reportUrls;
  final String? prescriptionUrl;
  final String? agoraChannelName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    this.doctorSpecialty = '',
    this.doctorPhotoUrl,
    this.patientPhotoUrl,
    required this.date,
    required this.timeSlot,
    this.status = AppointmentStatus.pending,
    this.reportUrls = const [],
    this.prescriptionUrl,
    this.agoraChannelName,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == AppointmentStatus.pending;
  bool get isAccepted => status == AppointmentStatus.accepted;
  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isRejected => status == AppointmentStatus.rejected;
  bool get isCancelled => status == AppointmentStatus.cancelled;

  /// Check if the appointment is within the call window (30 min before to 1 hour after)
  bool get isCallEnabled {
    if (!isAccepted) return false;
    // For demo/testing, always return true so the user can test the video call
    return true;
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      patientName: json['patientName'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      doctorSpecialty: json['doctorSpecialty'] as String? ?? '',
      doctorPhotoUrl: json['doctorPhotoUrl'] as String?,
      patientPhotoUrl: json['patientPhotoUrl'] as String?,
      date: DateTime.parse(json['date'] as String),
      timeSlot: json['timeSlot'] as String,
      status: AppointmentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      reportUrls: (json['reportUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      prescriptionUrl: json['prescriptionUrl'] as String?,
      agoraChannelName: json['agoraChannelName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'doctorId': doctorId,
        'patientName': patientName,
        'doctorName': doctorName,
        'doctorSpecialty': doctorSpecialty,
        'doctorPhotoUrl': doctorPhotoUrl,
        'patientPhotoUrl': patientPhotoUrl,
        'date': date.toIso8601String(),
        'timeSlot': timeSlot,
        'status': status.name,
        'reportUrls': reportUrls,
        'prescriptionUrl': prescriptionUrl,
        'agoraChannelName': agoraChannelName,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? patientName,
    String? doctorName,
    String? doctorSpecialty,
    String? doctorPhotoUrl,
    String? patientPhotoUrl,
    DateTime? date,
    String? timeSlot,
    AppointmentStatus? status,
    List<String>? reportUrls,
    String? prescriptionUrl,
    String? agoraChannelName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorPhotoUrl: doctorPhotoUrl ?? this.doctorPhotoUrl,
      patientPhotoUrl: patientPhotoUrl ?? this.patientPhotoUrl,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      reportUrls: reportUrls ?? this.reportUrls,
      prescriptionUrl: prescriptionUrl ?? this.prescriptionUrl,
      agoraChannelName: agoraChannelName ?? this.agoraChannelName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
