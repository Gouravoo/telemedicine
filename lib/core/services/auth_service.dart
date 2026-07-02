import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    yield _currentUser;
  }

  /// Sign in with email & password
  Future<UserModel> signInWithEmail(String email, String password) async {
    // TODO: Replace with Firebase Auth
    // final credential = await FirebaseAuth.instance
    //     .signInWithEmailAndPassword(email: email, password: password);
    // final uid = credential.user!.uid;
    // final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    // return UserModel.fromJson(doc.data()!);

    await Future.delayed(const Duration(milliseconds: 800));

    // Mock: determine role from email
    UserRole role = UserRole.patient;
    if (email.contains('doctor') || email.contains('dr')) {
      role = UserRole.doctor;
    } else if (email.contains('admin')) {
      role = UserRole.admin;
    }

    _currentUser = UserModel(
      uid: 'mock_${email.hashCode}',
      name: _nameFromEmail(email),
      email: email,
      phone: '+91 98765 43210',
      role: role,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    // TODO: Replace with Google Sign-In + Firebase Auth
    // final googleUser = await GoogleSignIn().signIn();
    // final googleAuth = await googleUser!.authentication;
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth.accessToken,
    //   idToken: googleAuth.idToken,
    // );
    // await FirebaseAuth.instance.signInWithCredential(credential);

    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      uid: 'google_mock_user',
      name: 'Rahul Sharma',
      email: 'rahul.sharma@gmail.com',
      phone: '+91 98765 43210',
      photoUrl: 'https://ui-avatars.com/api/?name=Rahul+Sharma&background=0F9D8C&color=fff&size=200',
      role: UserRole.patient,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  /// Register new patient
  Future<UserModel> registerPatient({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    // TODO: Replace with Firebase Auth + Firestore write
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      uid: 'new_${email.hashCode}',
      name: name,
      email: email,
      phone: phone,
      role: UserRole.patient,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    // TODO: FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Sign out
  Future<void> signOut() async {
    // TODO: await FirebaseAuth.instance.signOut();
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
