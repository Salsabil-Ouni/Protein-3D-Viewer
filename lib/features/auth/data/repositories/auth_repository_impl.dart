import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;

  AuthRepositoryImpl(this._remote);

  @override
  Future<User> login(String email, String password) async {
    try {
      return await _remote.login(email, password);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<User> register(
      String email, String password, String firstName, String lastName) async {
    try {
      return await _remote.register(email, password, firstName, lastName);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<void> logout() => _remote.logout();

  @override
  User? getCurrentUser() => _remote.getCurrentUser();

  @override
  Stream<User?> get authStateChanges => _remote.authStateChanges;
}
