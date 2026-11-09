import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _current;

  Future<void> init() async {
    _setCurrent(_auth.currentUser);
  }

  Map<String, dynamic>? get currentUser =>
      _current == null ? null : Map.unmodifiable(_current!);

  String get currentName {
    final name = _current?['name'] as String?;
    return name != null && name.trim().isNotEmpty ? name : 'User';
  }

  bool isLoggedIn() => _auth.currentUser != null;

  void _setCurrent(User? user) {
    if (user == null) {
      _current = null;
      return;
    }

    _current = {
      'uid': user.uid,
      'name': user.displayName ?? '',
      'email': user.email ?? '',
    };
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Your password is too weak. Use a stronger password.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'requires-recent-login':
        return 'Please log in again before changing your email.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();

      _setCurrent(_auth.currentUser);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    } catch (_) {
      return 'Unable to create your account. Please try again.';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _setCurrent(credential.user);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    } catch (_) {
      return 'Unable to log in. Please try again.';
    }
  }

  Future<String?> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    } catch (_) {
      return 'Unable to send the password reset email.';
    }
  }

  Future<String?> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return 'Please log in again.';
      }

      await user.updateDisplayName(name.trim());

      if (email.trim().toLowerCase() != (user.email ?? '').toLowerCase()) {
        await user.verifyBeforeUpdateEmail(email.trim());
      }

      await user.reload();
      _setCurrent(_auth.currentUser);

      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    } catch (_) {
      return 'Unable to update your profile. Please try again.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _setCurrent(null);
  }
}
