import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';

/// ──────────────────────────────────────────────────────────────
/// AUTH SERVICE — Supabase Migration
/// ──────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Stream of auth state changes
  Stream<UserModel?> authStateChanges() async* {
    await for (final authState in _supabase.auth.onAuthStateChange) {
      final user = authState.session?.user;
      if (user == null) {
        _currentUser = null;
        yield null;
      } else {
        try {
          final response = await _supabase
              .from('users')
              .select()
              .eq('uid', user.id)
              .maybeSingle();
              
          if (response != null) {
            _currentUser = UserModel.fromJson(response);
          } else {
            // Create default patient profile
            _currentUser = UserModel(
              uid: user.id,
              name: user.userMetadata?['full_name'] ?? _nameFromEmail(user.email ?? 'User'),
              email: user.email ?? '',
              role: UserRole.patient,
              createdAt: DateTime.now(),
            );
            await _supabase.from('users').insert(_currentUser!.toJson());
          }
        } catch (e) {
          print('Error fetching Supabase user profile: $e');
        }
        yield _currentUser;
      }
    }
  }

  Future<UserModel> signInWithEmail(String email, String password) async {
    // Demo login bypass
    if (email.endsWith('@demo.com')) {
      await Future.delayed(const Duration(seconds: 1));
      UserRole role = UserRole.patient;
      if (email.contains('doctor')) role = UserRole.doctor;
      if (email.contains('admin')) role = UserRole.admin;
      
      _currentUser = UserModel(
        uid: 'demo_${role.name}_123',
        name: 'Demo ${role.name.toUpperCase()}',
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );
      return _currentUser!;
    }

    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) throw Exception('Login failed');

      final response = await _supabase
          .from('users')
          .select()
          .eq('uid', user.id)
          .maybeSingle();
          
      if (response != null) {
        _currentUser = UserModel.fromJson(response);
      } else {
        // User profile doesn't exist yet (e.g., email confirmation was ON during registration)
        // Create it now using metadata from signUp
        final roleName = user.userMetadata?['role'] as String? ?? 'patient';
        final role = UserRole.values.firstWhere(
          (r) => r.name == roleName,
          orElse: () => UserRole.patient,
        );
        _currentUser = UserModel(
          uid: user.id,
          name: user.userMetadata?['full_name'] ?? email.split('@')[0],
          email: email,
          role: role,
          createdAt: DateTime.now(),
        );
        // Save to database
        await _supabase.from('users').upsert(_currentUser!.toJson());
      }
      return _currentUser!;
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      const webClientId = 'YOUR_GOOGLE_WEB_CLIENT_ID';
      const iosClientId = 'YOUR_GOOGLE_IOS_CLIENT_ID';
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in aborted');
      
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      
      if (accessToken == null || idToken == null) {
        throw Exception('No access token found');
      }

      final AuthResponse res = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      final user = res.user;
      if (user == null) throw Exception('Supabase auth failed');

      final response = await _supabase
          .from('users')
          .select()
          .eq('uid', user.id)
          .maybeSingle();
          
      if (response != null) {
        _currentUser = UserModel.fromJson(response);
      } else {
        _currentUser = UserModel(
          uid: user.id,
          name: user.userMetadata?['full_name'] ?? 'Google User',
          email: user.email ?? '',
          photoUrl: user.userMetadata?['avatar_url'],
          role: UserRole.patient,
          createdAt: DateTime.now(),
        );
        await _supabase.from('users').insert(_currentUser!.toJson());
      }
      return _currentUser!;
    } catch (e) {
      throw Exception('Google login failed: $e');
    }
  }

  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
    String? phone,
    UserRole role = UserRole.patient,
  }) async {
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name, 'role': role.name},
      );
      
      final user = res.user;
      if (user == null) throw Exception('Registration failed');
      
      _currentUser = UserModel(
        uid: user.id,
        name: name,
        email: email,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );
      
      // Only insert into users table if we have a valid session
      // (i.e., email confirmation is disabled in Supabase)
      if (res.session != null) {
        await _supabase.from('users').upsert(_currentUser!.toJson());
      }
      
      return _currentUser!;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _currentUser = null;
  }

  String _nameFromEmail(String email) {
    final name = email.split('@').first.replaceAll('.', ' ');
    return name.split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }
}
