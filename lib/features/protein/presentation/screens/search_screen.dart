import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../providers/protein_provider.dart';
import '../widgets/protein_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.trim().isEmpty) return;
    ref.read(searchProvider.notifier).search(query.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final history = ref.watch(proteinRepositoryProvider).getSearchHistory();
    final locale = ref.watch(localeProvider);
    final t = (String k) => AppL10n.tr(locale, k);

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'search-bar',
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: _ctrl,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: t('search_input_hint'),
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                border: InputBorder.none,
                filled: false,
              ),
              onSubmitted: _search,
            ),
          ),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _ctrl.clear();
                ref.read(searchProvider.notifier).clear();
              },
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _search(_ctrl.text),
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (state.isLoading) return _ShimmerList();
        if (state.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _search(state.query),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state.results.isNotEmpty) {
          return ListView.builder(
            itemCount: state.results.length,
            itemBuilder: (context, i) => ProteinCard(
              protein: state.results[i],
              onTap: () => context.go('/home/detail/${state.results[i].pdbId}'),
            ),
          );
        }
        // Show quick access suggestions
        return ListView(
          children: [
            if (history.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(t('search_recent'), style: Theme.of(context).textTheme.titleSmall),
              ),
              ...history.take(5).map((id) => Dismissible(
                    key: Key('search_hist_$id'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) async {
                      await ref.read(proteinRepositoryProvider).removeFromHistory(id);
                      ref.invalidate(proteinRepositoryProvider);
                    },
                    child: ListTile(
                      leading: const Icon(Icons.history, size: 18),
                      title: Text(id),
                      onTap: () {
                        _ctrl.text = id;
                        _search(id);
                      },
                    ),
                  )),
              const Divider(),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(t('search_quick'), style: Theme.of(context).textTheme.titleSmall),
            ),
            ...['1TUP (p53)', '4HHB (Hemoglobin)', '1MBO (Myoglobin)', '2LYZ (Lysozyme)']
                .map((s) => ListTile(
                      leading: const Icon(Icons.biotech_outlined, size: 18),
                      title: Text(s),
                      onTap: () {
                        final id = s.split(' ').first;
                        _ctrl.text = id;
                        _search(id);
                      },
                    )),
          ],
        );
      }),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(height: 100),
        ),
      ),
    );
  }
}
