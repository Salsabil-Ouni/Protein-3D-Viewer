import '../../domain/entities/protein.dart';
import '../../domain/entities/protein_detail.dart';
import '../../domain/repositories/protein_repository.dart';
import '../datasources/protein_local_datasource.dart';
import '../datasources/protein_remote_datasource.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';

class ProteinRepositoryImpl implements ProteinRepository {
  final ProteinRemoteDataSource _remote;
  final ProteinLocalDataSource _local;
  final NetworkInfo _networkInfo;

  ProteinRepositoryImpl(this._remote, this._local, this._networkInfo);

  @override
  Future<ProteinDetail> getProteinDetail(String pdbId) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      throw const NetworkFailure('No internet connection.');
    }
    try {
      return await _remote.getProteinDetail(pdbId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  Future<List<Protein>> searchProteins(String query) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) throw const NetworkFailure('No internet connection.');
    try {
      return await _remote.searchProteins(query);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  Stream<List<Protein>> favoritesStream(String uid) => _local.favoritesStream(uid);

  @override
  Future<void> addFavorite(String uid, Protein protein) => _local.addFavorite(uid, protein);

  @override
  Future<void> removeFavorite(String uid, String pdbId) => _local.removeFavorite(uid, pdbId);

  @override
  Future<bool> isFavorite(String uid, String pdbId) => _local.isFavorite(uid, pdbId);

  @override
  List<String> getSearchHistory() => _local.getSearchHistory();

  @override
  Future<void> addToHistory(String pdbId) => _local.addToHistory(pdbId);

  @override
  Future<void> removeFromHistory(String pdbId) => _local.removeFromHistory(pdbId);

  @override
  Future<void> clearHistory() => _local.clearHistory();
}
