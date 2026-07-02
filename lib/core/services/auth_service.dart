import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// ──────────────────────────────────────────────────────────────
/// AUTH SERVICE — All Firebase Auth operations in one place
/// ──────────────────────────────────────────────────────────────
/// When Firebase is connected, replace mock implementations
/// with actual Firebase Auth calls.
///
/// Usage: ref.read(authServiceProvider).signInWithEmail(...)
/// ──────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  // Current user state (mock)
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Stream of auth state changes
  Stream<UserModel?> authStateChanges() async* {
    await for (final user in FirebaseAuth.instance.authStateChanges()) {
      if (user == null) {
        _currentUser = null;
        yield null;
      } else {
        // Fetch user role from Firestore
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _currentUser = UserModel.fromJson(doc.data()!);
        } else {
          // If no doc exists, create a default patient profile
          _currentUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? _nameFromEmail(user.email ?? 'User'),
            email: user.email ?? '',
            role: UserRole.patient,
            createdAt: DateTime.now(),
          );
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set(_currentUser!.toJson());
        }
        yield _currentUser;
      }
    }
  }

  /// Sign in with email & password
  Future<UserModel> signInWithEmail(String email, String password) async {
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    final uid = credential.user!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    
    if (doc.exists) {
      _currentUser = UserModel.fromJson(doc.data()!);
    } else {
      throw Exception('User profile not found in database.');
    }
    return _currentUser!;
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    // For web, we can use signInWithPopup
    final googleProvider = GoogleAuthProvider();
    final credential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
    
    final uid = credential.user!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    
    if (doc.exists) {
      _currentUser = UserModel.fromJson(doc.data()!);
    } else {
      _currentUser = UserModel(
        uid: uid,
        name: credential.user!.displayName ?? 'Google User',
        email: credential.user!.email ?? '',
        photoUrl: credential.user!.photoURL,
        role: UserRole.patient, // Default to patient
        createdAt: DateTime.now(),
      );
      await FirebaseFirestore.instance.collection('users').doc(uid).set(_currentUser!.toJson());
    }
    
    return _currentUser!;
  }

  /// Register new patient
  Future<UserModel> registerPatient({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    
    await credential.user!.updateDisplayName(name);
    
    _currentUser = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      phone: phone,
      role: UserRole.patient,
      createdAt: DateTime.now(),
    );
    
    // Save to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .set(_currentUser!.toJson());
        
    return _currentUser!;
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  /// Sign out
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
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
