import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../../../../main.dart' show firebaseReady;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/protein.dart';
//api call 
abstract class ProteinLocalDataSource {
  Stream<List<Protein>> favoritesStream(String uid);
  Future<void> addFavorite(String uid, Protein protein);
  Future<void> removeFavorite(String uid, String pdbId);
  Future<bool> isFavorite(String uid, String pdbId);
  List<String> getSearchHistory();
  Future<void> addToHistory(String pdbId);
  Future<void> removeFromHistory(String pdbId);
  Future<void> clearHistory();
}

class ProteinLocalDataSourceImpl implements ProteinLocalDataSource {
  FirebaseFirestore? get _db => firebaseReady ? FirebaseFirestore.instance : null;
  Box<String> get _histBox => Hive.box<String>(AppConstants.historyBox);

  CollectionReference? _favRef(String uid) =>
      _db?.collection('users').doc(uid).collection('favorites');

  @override
  Stream<List<Protein>> favoritesStream(String uid) {
    final ref = _favRef(uid);
    if (ref == null) return Stream.value([]);
    return ref
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return _ProteinData(
                pdbId: d['pdbId'] as String,
                title: d['title'] as String,
                organism: d['organism'] as String,
                method: d['method'] as String,
                resolution: (d['resolution'] as num?)?.toDouble(),
                chainCount: (d['chainCount'] as num?)?.toInt() ?? 1,
                releaseDate: d['releaseDate'] as String,
                thumbnailUrl: d['thumbnailUrl'] as String?,
              );
            }).toList());
  }

  @override
  Future<void> addFavorite(String uid, Protein protein) async {
    final ref = _favRef(uid);
    if (ref == null) return;
    try {
      await ref.doc(protein.pdbId).set({
        'pdbId': protein.pdbId,
        'title': protein.title,
        'organism': protein.organism,
        'method': protein.method,
        'resolution': protein.resolution,
        'chainCount': protein.chainCount,
        'releaseDate': protein.releaseDate,
        'thumbnailUrl': protein.thumbnailUrl,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw CacheException('Failed to save favorite: $e');
    }
  }

  @override
  Future<void> removeFavorite(String uid, String pdbId) async {
    await _favRef(uid)?.doc(pdbId).delete();
  }

  @override
  Future<bool> isFavorite(String uid, String pdbId) async {
    final ref = _favRef(uid);
    if (ref == null) return false;
    final doc = await ref.doc(pdbId).get();
    return doc.exists;
  }

  @override
  List<String> getSearchHistory() {
    return _histBox.values.toList().reversed.toList();
  }

  @override
  Future<void> addToHistory(String pdbId) async {
    final existing = _histBox.values.toList();
    existing.remove(pdbId.toUpperCase());
    if (existing.length >= AppConstants.maxHistoryItems) existing.removeLast();
    await _histBox.clear();
    await _histBox.addAll([pdbId.toUpperCase(), ...existing]);
  }

  @override
  Future<void> removeFromHistory(String pdbId) async {
    final all = _histBox.values.toList();
    all.remove(pdbId.toUpperCase());
    await _histBox.clear();
    await _histBox.addAll(all);
  }

  @override
  Future<void> clearHistory() async => _histBox.clear();
}

// Simple Protein implementation for Firestore data
class _ProteinData extends Protein {
  const _ProteinData({
    required super.pdbId,
    required super.title,
    required super.organism,
    required super.method,
    super.resolution,
    required super.chainCount,
    required super.releaseDate,
    super.thumbnailUrl,
  });
}
