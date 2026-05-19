import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(
      String email, String password, String firstName, String lastName);
  Future<void> logout();
  UserModel? getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

// ── Firebase implementation ────────────────────────────────────────────────

class AuthFirebaseDataSource implements AuthRemoteDataSource {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _toModel(cred.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> register(
      String email, String password, String firstName, String lastName) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user!.updateDisplayName('$firstName $lastName'.trim());
      await cred.user!.reload();
      return _toModel(_auth.currentUser!);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  UserModel? getCurrentUser() {
    final u = _auth.currentUser;
    return u != null ? _toModel(u) : null;
  }

  @override
  Stream<UserModel?> get authStateChanges =>
      _auth.authStateChanges().map((u) => u != null ? _toModel(u) : null);

  UserModel _toModel(fb.User u) {
    final parts = (u.displayName ?? u.email ?? '').split(' ');
    return UserModel(
      id: u.uid.hashCode,
      uid: u.uid,
      email: u.email ?? '',
      firstName: parts.isNotEmpty ? parts.first : 'User',
      lastName: parts.length > 1 ? parts.last : '',
      token: null,
    );
  }

  String _mapError(String code) => switch (code) {
        'user-not-found' => 'No account found with this email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-credential' => 'Invalid email or password.',
        'email-already-in-use' => 'This email is already registered.',
        'weak-password' => 'Password too weak (min 6 characters).',
        'invalid-email' => 'Invalid email address.',
        'network-request-failed' => 'No internet connection.',
        'too-many-requests' => 'Too many attempts. Try again later.',
        _ => 'Authentication error: $code',
      };
}

// ── Local fallback (used when Firebase is not configured) ──────────────────

class AuthLocalDataSource implements AuthRemoteDataSource {
  static const _usersKey = 'registered_users';

  Future<Map<String, dynamic>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    debugPrint('🔍 Stored users: $raw');
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> _saveUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final users = await _loadUsers();
      final key = email.toLowerCase().trim();
      if (!users.containsKey(key)) {
        throw const AuthException('No account found. Please register first.');
      }
      final stored = users[key] as Map<String, dynamic>;
      if (stored['password'] != password) {
        throw const AuthException('Incorrect password.');
      }
      return UserModel(
        id: stored['id'] as int,
        uid: 'local_${stored['id']}',
        email: email,
        firstName: stored['first_name'] as String,
        lastName: stored['last_name'] as String,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(
      String email, String password, String firstName, String lastName) async {
    final users = await _loadUsers();
    final key = email.toLowerCase().trim();
    if (users.containsKey(key)) {
      throw const AuthException('This email is already registered.');
    }
    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    users[key] = {
      'id': id,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
    };
    await _saveUsers(users);
    return UserModel(
      id: id,
      uid: 'local_$id',
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_local_user');
  }

  @override
  UserModel? getCurrentUser() => null;

  @override
  Stream<UserModel?> get authStateChanges => const Stream.empty();
}
