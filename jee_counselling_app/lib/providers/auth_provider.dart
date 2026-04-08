import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/mentors/models/app_user_model.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  // Added the missing initialization flag here
  bool _isInitialized = false;

  String? _verificationId;
  String? get verificationId => _verificationId;

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

  Future<bool> sendPhoneOTP(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    Completer<bool> completer = Completer<bool>();

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolve on Android
          await FirebaseAuth.instance.signInWithCredential(credential);
          _isLoading = false;
          notifyListeners();
          if (!completer.isCompleted) completer.complete(true);
        },
        verificationFailed: (FirebaseAuthException e) {
          _error = e.message;
          _isLoading = false;
          notifyListeners();
          if (!completer.isCompleted) completer.complete(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _isLoading = false;
          notifyListeners();
          if (!completer.isCompleted) completer.complete(true);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      if (!completer.isCompleted) completer.complete(false);
    }
    return completer.future;
  }

  Future<bool> sendEmailOTP(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ---------------------------------------------------------
      // DEVELOPMENT MOCK
      // In a real production app, you MUST uncomment and configure 
      // the EmailOTP settings below with a real SMTP server.
      // For now, we mock the sending so you can test the UI.
      // ---------------------------------------------------------
      await Future.delayed(const Duration(seconds: 1)); // Simulate network request
      
      /*
      EmailOTP.config(
        appName: 'JEE Counselling App',
        otpType: OTPType.numeric,
        emailTheme: EmailTheme.v1,
      );
      
      EmailOTP.setSMTP(
        host: 'smtp.gmail.com',
        emailPort: EmailPort.port587,
        secureType: SecureType.tls,
        username: 'your-email@gmail.com',
        password: 'your-app-password',
      );

      bool res = await EmailOTP.sendOTP(email: email);
      if (!res) {
        _error = 'Failed to send OTP to $email. Ensure SMTP is configured in auth_provider.dart.';
      }
      return res;
      */

      _isLoading = false;
      notifyListeners();
      return true; // Always return true for development
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyEmailOTP(String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ---------------------------------------------------------
      // DEVELOPMENT MOCK
      // Accept '123456' as the universal test OTP.
      // ---------------------------------------------------------
      await Future.delayed(const Duration(milliseconds: 500));
      
      bool res = otp.trim() == '123456';
      
      /*
      // Production code:
      bool res = EmailOTP.verifyOTP(otp: otp);
      */
      
      if (!res) {
        _error = 'Invalid OTP. For testing purposes, please enter: 123456';
      }
      _isLoading = false;
      notifyListeners();
      return res;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOTP(String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_verificationId == null) {
        _error = 'Verification ID is null. Request OTP first.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
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

    try {
      // 1. Create the user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Send the verification email natively through Firebase!
      await userCredential.user?.sendEmailVerification();

      // 3. Save the extra user details locally so the UI knows their role
      final user = AppUser(
        id: userCredential.user!.uid, // Use Firebase UID securely
        name: name,
        email: email,
        passwordHash: _hashPassword(password), // Legacy local fallback
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
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
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
      // 1. Authenticate natively with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // 2. Enforce Email Verification!
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        _error = 'Please check your email inbox and verify your account first!';
        _isLoading = false;
        notifyListeners();
        
        // Optionally resend the verification email just in case
        await userCredential.user?.sendEmailVerification();
        return false;
      }

      // 3. Load extra role details from our database
      final user = await _storage.getUserByEmail(email);

      if (user == null) {
        // Auto-recover user from Firebase into local storage
        final prefix = email.split('@')[0];
        final generatedName = prefix[0].toUpperCase() + prefix.substring(1);

        final recoveredUser = AppUser(
          id: userCredential.user!.uid,
          name: generatedName, 
          email: email,
          passwordHash: _hashPassword(password),
          role: expectedRole,
        );
        await _storage.saveUser(recoveredUser);
        
        _currentUser = recoveredUser;
        await _storage.saveLoggedInUser(recoveredUser);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      if (user.role != expectedRole) {
        _error =
            'This account is registered as a ${user.role == UserRole.mentor ? "Mentor" : "Student"}.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      await _storage.saveLoggedInUser(user);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
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