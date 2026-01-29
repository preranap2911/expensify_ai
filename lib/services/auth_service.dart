import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  // ----------------------------
  // Auth state
  // ----------------------------
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // ----------------------------
  // Sign Up / Sign In / Sign Out
  // ----------------------------
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = cred.user!.uid;

    // Create/merge user profile doc
    await _db.collection('users').doc(uid).set({
      'email': email.trim(),
      'name': name.trim(),
      'phone': phone.trim(),
      'currency': 'GBP',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Optional: trigger verification email right after signup
    await sendEmailVerification();

    return cred;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  // ----------------------------
  // Email verification
  // ----------------------------
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // ----------------------------
  // Forgot password
  // ----------------------------
  Future<void> sendPasswordReset({
    required String email,
  }) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ----------------------------
  // Profile helpers
  // ----------------------------
  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? currency,
    String? photoUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'User is not signed in.',
      );
    }

    final data = <String, dynamic>{};

    if (name != null) data['name'] = name.trim();
    if (phone != null) data['phone'] = phone.trim();
    if (currency != null) data['currency'] = currency.trim().toUpperCase();
    if (photoUrl != null) data['photoUrl'] = photoUrl.trim();

    if (data.isEmpty) return;

    await _db.collection('users').doc(uid).set(
      data,
      SetOptions(merge: true),
    );
  }

  // ----------------------------
  // Friendly errors
  // ----------------------------
  String friendlyError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-disabled':
          return 'This account is disabled.';
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'Email is already registered.';
        case 'weak-password':
          return 'Password is too weak (use 6+ chars).';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Check your internet connection.';
        case 'not-authenticated':
          return 'Please log in again.';
        default:
          return e.message ?? 'Authentication error.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
