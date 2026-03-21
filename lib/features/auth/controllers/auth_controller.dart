import 'package:flutter/foundation.dart';
import 'package:sim_tchad/features/auth/models/LoginModel.dart';
import '../../../services/auth_service.dart';

class AuthController with ChangeNotifier {
  final AuthService authService;

  AuthController({required this.authService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // String? _userEmail;
  // String? get userEmail => _userEmail;

  Future<void> login(LoginModel login) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // final user = await authService.login(login.codeEnqueteur,login.passWord);
      // _userEmail = user.email;
      _isAuthenticated = true;
    } catch (e) {
      _error = 'Login failed: $e';
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _isAuthenticated = false;
    // _userEmail = null;
    _error = null;
    notifyListeners();
  }
}
