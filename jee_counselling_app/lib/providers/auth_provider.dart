import 'package:flutter/foundation.dart';
import 'dart:math';
import '../screens/mentors/models/app_user_model.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  // Added the missing initialization flag here
  bool _isInitialized = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Added the getter so main.dart can read it
  bool get isInitialized => _isInitialized;
  
  bool get isLoggedIn => _currentUser != null;
  bool get isMentor => _currentUser?.role == UserRole.mentor;
  bool get isStudent => _currentUser?.role == UserRole.student;

  Future<void> init() async {
    _currentUser = await _storage.getLoggedInUser();
    
    // Set to true after loading from storage
    _isInitialized = true;
    
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    // Student fields
    int? jeeRank,
    String? jeeType,
    // Mentor fields
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

    final exists = await _storage.emailExists(email);
    if (exists) {
      _error = 'An account with this email already exists.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final user = AppUser(
      id: _generateId(),
      name: name,
      email: email,
      passwordHash: _hashPassword(password),
      role: role,
      jeeRank: jeeRank,
      jeeType: jeeType,
      college: college,
      branch: branch,
      year: year,
      expertise: expertise ?? [],
      sessionPrice: sessionPrice ?? 0,
      mentorJeeRank: mentorJeeRank,
      mentorJeeType: mentorJeeType,
      bio: bio,
    );

    await _storage.saveUser(user);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
    required UserRole expectedRole,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final user = await _storage.getUserByEmail(email);

    if (user == null) {
      _error = 'No account found with this email.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (user.role != expectedRole) {
      _error =
          'This account is registered as a ${user.role == UserRole.mentor ? "Mentor" : "Student"}.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (user.passwordHash != _hashPassword(password)) {
      _error = 'Incorrect password.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _currentUser = user;
    await _storage.saveLoggedInUser(user);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _storage.logout();
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _generateId() {
    final rand = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() +
        rand.nextInt(9999).toString();
  }

  String _hashPassword(String password) {
    int hash = 0;
    for (var ch in password.codeUnits) {
      hash = (hash * 31 + ch) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }
}