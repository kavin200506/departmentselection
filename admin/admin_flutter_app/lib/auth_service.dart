import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<bool> signInWithEmailAndPassword(String email, String password, String department) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Firebase authentication
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;

      // Store department in user metadata
      await _user?.updateDisplayName(department);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Sign in error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
