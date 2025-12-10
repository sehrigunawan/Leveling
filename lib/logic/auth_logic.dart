import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_services.dart'; 
import '../data/models/user_model.dart'; 

class AuthLogic extends ChangeNotifier { // <--- BUKA KURUNG CLASS
  final AuthService _authService = AuthService();

  // Variables
  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = true;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _firebaseUser != null;

  // Constructor
  AuthLogic() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        _isLoading = true;
        notifyListeners();
        _userModel = await _authService.getUserProfile(user.uid);
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  // --- LOGIN EMAIL ---
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners(); // <--- Ini tidak akan error jika di dalam class

    final result = await _authService.login(email, password);
    
    if (result['success'] == false) {
      _isLoading = false;
      notifyListeners();
      return result['error'];
    }
    return null; 
  }

  // --- LOGIN GOOGLE ---
  Future<String?> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.signInWithGoogle();

    if (result['success'] == false) {
      _isLoading = false;
      notifyListeners();
      return result['error'];
    }
    return null;
  }

  // --- REGISTER ---
  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String selectedCharacter,
    required String petName,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(
      email: email,
      password: password,
      name: name,
      selectedCharacter: selectedCharacter,
      petName: petName,
    );

    if (result['success'] == false) {
      _isLoading = false;
      notifyListeners();
      return result['error'];
    }
    return null;
  }

  // --- CEK EMAIL ---
  Future<bool> checkEmailExists(String email) async {
    return await _authService.isEmailRegistered(email);
  }
  
  // --- RESET PASSWORD ---
  Future<void> sendResetLink(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _authService.logout();
  }

}