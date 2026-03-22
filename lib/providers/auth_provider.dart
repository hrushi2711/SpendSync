import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepo;
  UserModel? _currentUser;

  AuthProvider(this._userRepo);

  bool get isLoggedIn => _currentUser != null;
  UserModel? get currentUser => _currentUser;
  int get currentUserId => _currentUser?.id ?? 0;

  /// Returns error message or null on success.
  String? login(String username, String password) {
    if (username.trim().isEmpty || password.isEmpty) {
      return 'Please fill in all fields';
    }
    final user = _userRepo.login(username.trim(), password);
    if (user == null) return 'Invalid username or password';
    _currentUser = user;
    notifyListeners();
    return null;
  }

  /// Returns error message or null on success.
  Future<String?> signup(String username, String password, String confirmPassword) async {
    if (username.trim().isEmpty || password.isEmpty) {
      return 'Please fill in all fields';
    }
    if (password.length < 4) {
      return 'Password must be at least 4 characters';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    final user = await _userRepo.signup(username.trim(), password);
    if (user == null) return 'Username already taken';
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
