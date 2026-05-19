import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/protein_provider.dart';
import '../widgets/protein_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).user?.uid ?? '';
    final favAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: favAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (favorites) => favorites.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('No favorites yet',
                        style: TextStyle(color: Colors.grey, fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text('Tap the heart icon on any protein to save it',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ).animate().fadeIn(),
              )
            : ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, i) => ProteinCard(
                  protein: favorites[i],
                  isFavorite: true,
                  onTap: () => context.go('/home/detail/${favorites[i].pdbId}'),
                  onFavoriteTap: () async {
                    await ref
                        .read(proteinRepositoryProvider)
                        .removeFavorite(uid, favorites[i].pdbId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${favorites[i].pdbId} removed from favorites'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
      ),
    );
  }
}
