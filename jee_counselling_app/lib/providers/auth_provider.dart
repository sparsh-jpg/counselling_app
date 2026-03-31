import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/mentors/models/app_user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _currentUser != null;
  bool get isMentor => _currentUser?.role == UserRole.mentor;
  bool get isStudent => _currentUser?.role == UserRole.student;
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> init() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      _currentUser = await _fetchUserFromFirestore(firebaseUser.uid);
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    int? jeeRank,
    String? jeeType,
    String? college,
    String? branch,
    int? year,
    List<String>? expertise,
    int? sessionPrice,
    int? mentorJeeRank,
    String? mentorJeeType,
    String? bio,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      final userData = {
        'id': uid,
        'name': name,
        'email': email,
        'role': role == UserRole.student ? 'student' : 'mentor',
        'createdAt': FieldValue.serverTimestamp(),
        if (role == UserRole.student) ...{
          'jeeRank': jeeRank,
          'jeeType': jeeType ?? 'JEE Main',
        },
        if (role == UserRole.mentor) ...{
          'college': college ?? '',
          'branch': branch ?? '',
          'year': year,
          'expertise': expertise ?? [],
          'sessionPrice': sessionPrice ?? 0,
          'mentorJeeRank': mentorJeeRank,
          'mentorJeeType': mentorJeeType ?? 'JEE Main',
          'bio': bio ?? '',
        },
      };

      await _db.collection('users').doc(uid).set(userData);
      await cred.user!.sendEmailVerification();

      _isLoading = false;
      notifyListeners();
      return true;

    } on FirebaseAuthException catch (e) {
      _error = _friendlyAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required UserRole expectedRole,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = await _fetchUserFromFirestore(cred.user!.uid);

      if (user == null) {
        _error = 'User data not found. Please contact support.';
        await _auth.signOut();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (user.role != expectedRole) {
        final wrongRole = user.role == UserRole.mentor ? 'Mentor' : 'Student';
        _error = 'This account is registered as a $wrongRole.';
        await _auth.signOut();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;

    } on FirebaseAuthException catch (e) {
      _error = _friendlyAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<AppUser?> _fetchUserFromFirestore(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return AppUser(
        id: uid,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        passwordHash: '',
        role: data['role'] == 'mentor' ? UserRole.mentor : UserRole.student,
        jeeRank: data['jeeRank'],
        jeeType: data['jeeType'],
        college: data['college'],
        branch: data['branch'],
        year: data['year'],
        expertise: List<String>.from(data['expertise'] ?? []),
        sessionPrice: data['sessionPrice'] ?? 0,
        mentorJeeRank: data['mentorJeeRank'],
        mentorJeeType: data['mentorJeeType'],
        bio: data['bio'],
      );
    } catch (_) {
      return null;
    }
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}