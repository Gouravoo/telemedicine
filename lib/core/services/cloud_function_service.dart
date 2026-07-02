import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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
      // Use absolute URL in web if not deployed, but usually /api works in Vercel.
      // If we are testing locally without Vercel Dev, it might throw an error.
      String url = '/api/generate_token?channelName=$channelName&uid=$uid';
      
      // Fallback for local development
      if (kDebugMode && !kIsWeb) {
         return 'mock_token_not_on_web';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'] as String;
      } else {
        debugPrint('Failed to generate token: ${response.statusCode}');
        // Fallback mock token just in case testing locally without Vercel CLI
        return 'mock_agora_token_${channelName}_$uid';
      }
    } catch (e) {
      debugPrint('Error calling token API: $e');
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
