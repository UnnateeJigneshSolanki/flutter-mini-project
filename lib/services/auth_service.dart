import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'currentUser';

  Future<Map<String, String>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_usersKey);
    if (stored != null) {
      return Map<String, String>.from(jsonDecode(stored));
    }
    return {};
  }

  Future<void> _saveUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<String?> getLoggedInUsername() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_currentUserKey);
}



  String _hashPassword(String password) {
    final codeUnits = password.codeUnits;
    final hash = codeUnits.fold<int>(0, (prev, elem) => prev + elem * 31);
    return hash.toString();
  }

  Future<bool> register(String username, String password) async {
    final users = await _loadUsers();
    if (users.containsKey(username)) return false;

    users[username] = _hashPassword(password);
    await _saveUsers(users);

  
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, username);
    return true;
  }

  Future<bool> login(String username, String password) async {
    final users = await _loadUsers();
    if (users[username] == _hashPassword(password)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, username);
      return true;
    }
    return false;
  }


  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey) != null;
  }

  Future<String?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }
}
