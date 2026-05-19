import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../main.dart' show firebaseReady;
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return firebaseReady ? AuthFirebaseDataSource() : AuthLocalDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    // Always start logged out so login screen is shown on every app launch
    _repository.logout();
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.login(email, password);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      final msg = e is Failure ? e.message : e.toString();
      debugPrint('🔴 Login Error: $msg');
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }

  Future<bool> register(
      String email, String password, String firstName, String lastName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user =
          await _repository.register(email, password, firstName, lastName);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      final msg = e is Failure ? e.message : e.toString();
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
