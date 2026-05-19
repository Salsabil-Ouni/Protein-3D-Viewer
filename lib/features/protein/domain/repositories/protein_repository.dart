import '../entities/protein.dart';
import '../entities/protein_detail.dart';

abstract class ProteinRepository {
  Future<ProteinDetail> getProteinDetail(String pdbId);
  Future<List<Protein>> searchProteins(String query);
  Stream<List<Protein>> favoritesStream(String uid);
  Future<void> addFavorite(String uid, Protein protein);
  Future<void> removeFavorite(String uid, String pdbId);
  Future<bool> isFavorite(String uid, String pdbId);
  List<String> getSearchHistory();
  Future<void> addToHistory(String pdbId);
  Future<void> removeFromHistory(String pdbId);
  Future<void> clearHistory();
}
