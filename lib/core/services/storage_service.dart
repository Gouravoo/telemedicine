import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ──────────────────────────────────────────────────────────────
/// STORAGE SERVICE — Firebase Storage operations
/// ──────────────────────────────────────────────────────────────
/// Handles file uploads/downloads for reports, prescriptions,
/// profile photos, and health tip images.
/// ──────────────────────────────────────────────────────────────

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

class StorageService {
  /// Upload a file and return the download URL
  Future<String> uploadFile({
    required String path,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    // TODO: Replace with Firebase Storage
    // final ref = FirebaseStorage.instance.ref('$path/$fileName');
    // final uploadTask = ref.putData(Uint8List.fromList(fileBytes));
    // final snapshot = await uploadTask;
    // return await snapshot.ref.getDownloadURL();

    await Future.delayed(const Duration(milliseconds: 800));
    return 'https://storage.example.com/$path/$fileName';
  }

  /// Upload profile photo
  Future<String> uploadProfilePhoto(String uid, List<int> fileBytes) async {
    return uploadFile(
      path: 'profiles/$uid',
      fileBytes: fileBytes,
      fileName: 'profile.jpg',
    );
  }

  /// Upload medical report
  Future<String> uploadReport({
    required String patientId,
    required String appointmentId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    return uploadFile(
      path: 'reports/$patientId/$appointmentId',
      fileBytes: fileBytes,
      fileName: fileName,
    );
  }

  /// Upload prescription
  Future<String> uploadPrescription({
    required String doctorId,
    required String appointmentId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    return uploadFile(
      path: 'prescriptions/$doctorId/$appointmentId',
      fileBytes: fileBytes,
      fileName: fileName,
    );
  }

  /// Upload health tip image
  Future<String> uploadHealthTipImage(
      String tipId, List<int> fileBytes) async {
    return uploadFile(
      path: 'health_tips/$tipId',
      fileBytes: fileBytes,
      fileName: 'cover.jpg',
    );
  }

  /// Delete a file by URL
  Future<void> deleteFile(String fileUrl) async {
    // TODO: FirebaseStorage.instance.refFromURL(fileUrl).delete();
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
