/// Report model stored in Firestore `reports` collection
class ReportModel {
  final String id;
  final String patientId;
  final String? appointmentId;
  final String fileUrl;
  final String fileName;
  final DateTime uploadedAt;

  const ReportModel({
    required this.id,
    required this.patientId,
    this.appointmentId,
    required this.fileUrl,
    required this.fileName,
    required this.uploadedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      appointmentId: json['appointmentId'] as String?,
      fileUrl: json['fileUrl'] as String,
      fileName: json['fileName'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'appointmentId': appointmentId,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'uploadedAt': uploadedAt.toIso8601String(),
      };
}
