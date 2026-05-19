import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../main.dart' show firebaseReady;
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../providers/protein_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/protein_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final uid = user?.uid ?? '';
    final locale = ref.watch(localeProvider);
    final t = (String k) => AppL10n.tr(locale, k);
    final history = ref.watch(proteinRepositoryProvider).getSearchHistory();
    final favAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('app_name')),
        actions: [
          // Theme toggle
          IconButton(
            icon: Icon(ThemeNotifier.iconFor(ref.watch(themeProvider))),
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
          ),
          // Language toggle
          TextButton(
            onPressed: () => ref.read(localeProvider.notifier).toggle(),
            child: Text(
              t('lang_toggle'),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => context.go('/home/favorites'),
          ),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(
                user?.firstName.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            itemBuilder: (_) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                enabled: false,
                child: ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    color: firebaseReady ? Colors.orange : Colors.grey,
                  ),
                  title: Text(user?.fullName ?? 'User'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.email ?? ''),
                      Row(
                        children: [
                          Icon(
                            firebaseReady ? Icons.cloud_done : Icons.storage,
                            size: 12,
                            color:
                                firebaseReady ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            firebaseReady ? 'Firebase' : 'Local',
                            style: TextStyle(
                              fontSize: 11,
                              color: firebaseReady
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(t('sign_out'),
                      style: const TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authStateProvider.notifier).logout();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Offline banner at the very top
          const OfflineBanner(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _SearchBar(locale: locale)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(t('featured'),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverToBoxAdapter(child: _FeaturedProteins()),
                if (history.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        children: [
                          Text(t('recent'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .read(proteinRepositoryProvider)
                                  .clearHistory();
                              ref.invalidate(proteinRepositoryProvider);
                            },
                            child: Text(t('clear')),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Dismissible(
                        key: Key('hist_${history[i]}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          await ref
                              .read(proteinRepositoryProvider)
                              .removeFromHistory(history[i]);
                          ref.invalidate(proteinRepositoryProvider);
                        },
                        child: ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(history[i]),
                          onTap: () =>
                              context.go('/home/detail/${history[i]}'),
                        ).animate().fadeIn(delay: (i * 50).ms),
                      ),
                      childCount: history.length.clamp(0, 5),
                    ),
                  ),
                ],
                favAsync.when(
                  loading: () =>
                      const SliverToBoxAdapter(child: SizedBox.shrink()),
                  error: (_, __) =>
                      const SliverToBoxAdapter(child: SizedBox.shrink()),
                  data: (favorites) => favorites.isEmpty
                      ? const SliverToBoxAdapter(child: SizedBox.shrink())
                      : SliverMainAxisGroup(slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 20, 16, 8),
                              child: Text(t('my_favorites'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => ProteinCard(
                                protein: favorites[i],
                                isFavorite: true,
                                onTap: () => context.go(
                                    '/home/detail/${favorites[i].pdbId}'),
                                onFavoriteTap: () async {
                                  await ref
                                      .read(proteinRepositoryProvider)
                                      .removeFavorite(
                                          uid, favorites[i].pdbId);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${favorites[i].pdbId} ${AppL10n.tr(locale, 'removed_fav')}'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                              ),
                              childCount: favorites.length.clamp(0, 3),
                            ),
                          ),
                        ]),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/home/search'),
        icon: const Icon(Icons.search),
        label: Text(t('search_pdb')),
      ),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  final String locale;
  const _SearchBar({required this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () => context.go('/home/search'),
        child: Hero(
          tag: 'search-bar',
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Theme.of(context).cardColor,
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(AppL10n.tr(locale, 'search_hint'),
                      style:
                          TextStyle(color: Colors.grey[500], fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2);
  }
}

class _FeaturedProteins extends StatelessWidget {
  static const featured = [
    ('4HHB', 'Hemoglobin'),
    ('1MBO', 'Myoglobin'),
    ('2LYZ', 'Lysozyme'),
    ('1CRN', 'Crambin'),
    ('1TUP', 'p53 Tumor Suppressor'),
    ('1AKE', 'Adenylate Kinase'),
    ('1BNA', 'DNA B-Form'),
    ('3NIR', 'Insulin'),
    ('1HHO', 'Oxy-Hemoglobin'),
    ('1GZX', 'Tropomyosin'),
    ('2HHB', 'Deoxy-Hemoglobin'),
    ('1AON', 'GroEL Chaperonin'),
    ('1RYT', 'Trypsin'),
    ('1ATN', 'Actin'),
    ('6LU7', 'COVID-19 Protease'),
    ('1HIV', 'HIV Protease'),
    ('1IGT', 'Immunoglobulin'),
    ('3HHR', 'Growth Hormone'),
    ('1F88', 'Rhodopsin'),
    ('1S5L', 'Collagen'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: featured.length,
      itemBuilder: (context, i) {
        final (id, name) = featured[i];
        return GestureDetector(
          onTap: () => context.go('/home/detail/$id'),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(id,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(name,
                        style: const TextStyle(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: (i * 50).ms);
      },
    );
  }
}
