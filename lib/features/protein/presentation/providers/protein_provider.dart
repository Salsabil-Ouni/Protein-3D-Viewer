import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/protein_local_datasource.dart';
import '../../data/datasources/protein_remote_datasource.dart';
import '../../data/repositories/protein_repository_impl.dart';
import '../../domain/entities/protein.dart';
import '../../domain/entities/protein_detail.dart';
import '../../domain/repositories/protein_repository.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final proteinLocalDataSourceProvider = Provider<ProteinLocalDataSource>(
  (_) => ProteinLocalDataSourceImpl(),
);

final proteinRemoteDataSourceProvider = Provider<ProteinRemoteDataSource>((ref) {
  return ProteinRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

final proteinRepositoryProvider = Provider<ProteinRepository>((ref) {
  return ProteinRepositoryImpl(
    ref.watch(proteinRemoteDataSourceProvider),
    ref.watch(proteinLocalDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

// Current user's uid (empty string if not logged in)
final currentUidProvider = Provider<String>((ref) {
  return ref.watch(authStateProvider).user?.uid ?? '';
});

// Firestore stream of favorites
final favoritesProvider = StreamProvider<List<Protein>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid.isEmpty) return const Stream.empty();
  return ref.watch(proteinRepositoryProvider).favoritesStream(uid);
});

// --- Search ---
class SearchState {
  final List<Protein> results;
  final bool isLoading;
  final String? error;
  final String query;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
  });

  SearchState copyWith({List<Protein>? results, bool? isLoading, String? error, String? query}) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final ProteinRepository _repository;

  SearchNotifier(this._repository) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    state = state.copyWith(isLoading: true, error: null, query: query);
    try {
      final results = await _repository.searchProteins(query);
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() => state = const SearchState();
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(proteinRepositoryProvider));
});

// --- Protein detail ---
class ProteinDetailState {
  final ProteinDetail? protein;
  final bool isLoading;
  final String? error;
  final bool isFavorite;

  const ProteinDetailState({
    this.protein,
    this.isLoading = false,
    this.error,
    this.isFavorite = false,
  });

  ProteinDetailState copyWith({
    ProteinDetail? protein,
    bool? isLoading,
    String? error,
    bool? isFavorite,
  }) {
    return ProteinDetailState(
      protein: protein ?? this.protein,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class ProteinDetailNotifier extends StateNotifier<ProteinDetailState> {
  final ProteinRepository _repository;
  final String _uid;

  ProteinDetailNotifier(this._repository, this._uid)
      : super(const ProteinDetailState());

  Future<void> loadProtein(String pdbId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addToHistory(pdbId);
      final protein = await _repository.getProteinDetail(pdbId);
      final isFav = _uid.isNotEmpty
          ? await _repository.isFavorite(_uid, pdbId)
          : false;
      state = state.copyWith(protein: protein, isLoading: false, isFavorite: isFav);
    } catch (e) {
      final msg = e is Failure ? e.message : e.toString();
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  Future<void> toggleFavorite() async {
    final protein = state.protein;
    if (protein == null || _uid.isEmpty) return;
    if (state.isFavorite) {
      await _repository.removeFavorite(_uid, protein.pdbId);
    } else {
      await _repository.addFavorite(_uid, protein);
    }
    state = state.copyWith(isFavorite: !state.isFavorite);
  }
}

final proteinDetailProvider =
    StateNotifierProvider.family<ProteinDetailNotifier, ProteinDetailState, String>(
  (ref, pdbId) => ProteinDetailNotifier(
    ref.watch(proteinRepositoryProvider),
    ref.watch(currentUidProvider),
  ),
);
