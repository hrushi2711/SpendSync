import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';

class UserRepository extends ChangeNotifier {
  static const String _boxName = 'usersBox';
  late Box<UserModel> _box;

  List<UserModel> get users => _box.values.toList();

  Future<void> init() async {
    _box = await Hive.openBox<UserModel>(_boxName);

    // Seed default admin account if not exists
    if (getByUsername('admin') == null) {
      final admin = UserModel(
        id: _nextId(),
        username: 'admin',
        passwordHash: _hashPassword('Admin123'),
        createdAt: DateTime.now(),
      );
      await _box.add(admin);
    }
  }

  int _nextId() {
    if (_box.isEmpty) return 1;
    return _box.values.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  UserModel? getByUsername(String username) {
    try {
      return _box.values
          .firstWhere((u) => u.username.toLowerCase() == username.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  UserModel? getById(int id) {
    try {
      return _box.values.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns the created user, or null if username already exists.
  Future<UserModel?> signup(String username, String password) async {
    if (getByUsername(username) != null) return null;

    final user = UserModel(
      id: _nextId(),
      username: username.trim(),
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );
    await _box.add(user);
    notifyListeners();
    return user;
  }

  /// Returns the user if credentials match, null otherwise.
  UserModel? login(String username, String password) {
    final user = getByUsername(username);
    if (user == null) return null;
    if (user.passwordHash != _hashPassword(password)) return null;
    return user;
  }

  bool get isEmpty => _box.isEmpty;
}
