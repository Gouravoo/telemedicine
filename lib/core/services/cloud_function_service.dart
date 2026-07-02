import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// ──────────────────────────────────────────────────────────────
/// CLOUD FUNCTION SERVICE — Firebase Cloud Function calls
/// ──────────────────────────────────────────────────────────────
/// All callable function wrappers in one place.
/// ──────────────────────────────────────────────────────────────

final cloudFunctionServiceProvider =
    Provider<CloudFunctionService>((ref) => CloudFunctionService());

class CloudFunctionService {
  Future<String> generateAgoraToken({
    required String channelName,
    required String uid,
  }) async {
    try {
      if (kDebugMode && !kIsWeb && const bool.fromEnvironment('MOCK_AGORA', defaultValue: false)) {
         return 'mock_token_not_on_web';
      }

      final response = await Supabase.instance.client.functions.invoke(
        'agora-token',
        body: {'channelName': channelName, 'uid': uid},
      );

      if (response.status == 200) {
        return response.data['token'] as String;
      } else {
        debugPrint('Failed to generate token: ${response.status} - ${response.data}');
        return 'mock_agora_token_${channelName}_$uid';
      }
    } catch (e) {
      debugPrint('Error calling Supabase edge function: $e');
      return 'mock_agora_token_${channelName}_$uid';
    }
  }

  /// Create a doctor account (Admin only)
  Future<void> createDoctorAccount({
    required String email,
    required String password,
    required String name,
    required String specialty,
  }) async {
    // TODO: Cloud Function creates Firebase Auth user + Firestore doc
    // final callable = FirebaseFunctions.instance.httpsCallable('createDoctorAccount');
    // await callable.call({
    //   'email': email, 'password': password,
    //   'name': name, 'specialty': specialty,
    // });

    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Send push notification
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String? type,
  }) async {
    // TODO: Cloud Function sends FCM notification
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
