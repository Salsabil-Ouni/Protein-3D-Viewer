import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../features/ai/presentation/providers/ai_provider.dart';
import '../providers/protein_provider.dart';
import '../widgets/viewer_3d.dart';
import '../widgets/property_chart.dart';
import '../../domain/entities/protein_detail.dart';

class ProteinDetailScreen extends ConsumerStatefulWidget {
  final String pdbId;
  const ProteinDetailScreen({super.key, required this.pdbId});

  @override
  ConsumerState<ProteinDetailScreen> createState() => _ProteinDetailScreenState();
}

class _ProteinDetailScreenState extends ConsumerState<ProteinDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(proteinDetailProvider(widget.pdbId).notifier).loadProtein(widget.pdbId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(proteinDetailProvider(widget.pdbId));
    final locale = ref.watch(localeProvider);
    final t = (String k) => AppL10n.tr(locale, k);

    return Scaffold(
      body: Builder(builder: (_) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return _ErrorView(
            error: state.error!,
            retryLabel: t('retry'),
            onRetry: () => ref
                .read(proteinDetailProvider(widget.pdbId).notifier)
                .loadProtein(widget.pdbId),
          );
        }
        if (state.protein == null) return const SizedBox.shrink();

        final protein = state.protein!;
        return NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              actions: [
                IconButton(
                  icon: Icon(ThemeNotifier.iconFor(ref.watch(themeProvider))),
                  tooltip: 'Toggle theme',
                  onPressed: () => ref.read(themeProvider.notifier).toggle(),
                ),
                IconButton(
                  icon: Icon(
                    state.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: state.isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: () async {
                    final wasFav = state.isFavorite;
                    await ref
                        .read(proteinDetailProvider(widget.pdbId).notifier)
                        .toggleFavorite();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${protein.pdbId} ${wasFav ? t('removed_fav') : t('added_fav')}',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(protein.pdbId,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                background: Viewer3D(pdbId: widget.pdbId),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: t('overview')),
                  Tab(text: t('properties')),
                  Tab(text: t('sequence')),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 14),
                        const SizedBox(width: 4),
                        Text(t('ai_analysis')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(protein: protein, locale: locale),
              _PropertiesTab(properties: protein.properties, locale: locale),
              _SequenceTab(protein: protein, locale: locale),
              _AiTab(protein: protein, pdbId: widget.pdbId, locale: locale),
            ],
          ),
        );
      }),
    );
  }
}

// ── Overview ──────────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final ProteinDetail protein;
  final String locale;
  const _OverviewTab({required this.protein, required this.locale});

  @override
  Widget build(BuildContext context) {
    final t = (String k) => AppL10n.tr(locale, k);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: t('basic_info'),
          child: Column(children: [
            _InfoTile(t('pdb_id'), protein.pdbId),
            _InfoTile(t('title'), protein.title),
            _InfoTile(t('organism'), protein.organism),
            _InfoTile(t('method'), protein.method),
            if (protein.resolution != null)
              _InfoTile(t('resolution'), '${protein.resolution!.toStringAsFixed(2)} Å'),
            _InfoTile(t('chains'), protein.chainCount.toString()),
            _InfoTile(t('released'), protein.releaseDate.split('T').first),
          ]),
        ).animate().fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => launchUrl(
            Uri.parse('https://files.rcsb.org/download/${protein.pdbId}.pdb'),
            mode: LaunchMode.externalApplication,
          ),
          icon: const Icon(Icons.download_outlined, size: 18),
          label: Text(t('download_pdb')),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 12),
        if (protein.keywords.isNotEmpty)
          _SectionCard(
            title: t('keywords'),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: protein.keywords
                  .take(8)
                  .map((k) => Chip(
                        label: Text(k, style: const TextStyle(fontSize: 12)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        const SizedBox(height: 12),
        _SectionCard(
          title: '${t('chains')} (${protein.chains.length})',
          child: Column(
            children: protein.chains
                .map((c) => _InfoTile(
                      'Chain ${c.chainId}',
                      '${c.residueCount} ${t('residues')}${c.description != null ? ' • ${c.description}' : ''}',
                    ))
                .toList(),
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
      ],
    );
  }
}

// ── Properties ────────────────────────────────────────────────────────────────

class _PropertiesTab extends StatelessWidget {
  final PhysicoChemicalProperties properties;
  final String locale;
  const _PropertiesTab({required this.properties, required this.locale});

  @override
  Widget build(BuildContext context) {
    final t = (String k) => AppL10n.tr(locale, k);
    final stability = properties.instabilityIndex > 40 ? t('unstable') : t('stable');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: t('physicochemical'),
          child: Column(children: [
            _InfoTile(t('mol_weight'),
                '${properties.molecularWeight.toStringAsFixed(2)} kDa'),
            _InfoTile(t('iso_point'),
                properties.isoelectricPoint.toStringAsFixed(2)),
            _InfoTile(t('instability'),
                '${properties.instabilityIndex.toStringAsFixed(1)} ($stability)'),
            _InfoTile(t('aliphatic'),
                properties.aliphaticIndex.toStringAsFixed(1)),
            _InfoTile('GRAVY', properties.gravy.toStringAsFixed(3)),
          ]),
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        _SectionCard(
          title: t('radar'),
          child: PropertyRadarChart(properties: properties),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 16),
        _SectionCard(
          title: t('aa_composition'),
          child: AminoAcidChart(properties: properties),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}

// ── Sequence ──────────────────────────────────────────────────────────────────

class _SequenceTab extends StatelessWidget {
  final ProteinDetail protein;
  final String locale;
  const _SequenceTab({required this.protein, required this.locale});

  @override
  Widget build(BuildContext context) {
    final t = (String k) => AppL10n.tr(locale, k);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: protein.chains.map((chain) {
        return _SectionCard(
          title: 'Chain ${chain.chainId} — ${chain.residueCount} ${t('residues')}',
          action: chain.sequence != null
              ? IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: t('copy_sequence'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: chain.sequence!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t('copied')),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                )
              : null,
          child: chain.sequence != null
              ? _SequenceViewer(sequence: chain.sequence!)
              : Text(t('seq_not_available'),
                  style: const TextStyle(color: Colors.grey)),
        ).animate().fadeIn();
      }).toList(),
    );
  }
}

// ── AI Analysis ───────────────────────────────────────────────────────────────

class _AiTab extends ConsumerWidget {
  final ProteinDetail protein;
  final String pdbId;
  final String locale;
  const _AiTab({required this.protein, required this.pdbId, required this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiAnalysisProvider(pdbId));
    final t = (String k) => AppL10n.tr(locale, k);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.auto_awesome,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(t('ai_title'),
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 4),
                  Text(t('ai_subtitle'),
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const Divider(height: 24),

                  // ── States ──
                  if (state.isLoading)
                    Column(children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(t('ai_analyzing'),
                          style: const TextStyle(color: Colors.grey)),
                    ]).animate().fadeIn()
                  else if (state.error == 'KEY_MISSING')
                    _AiMessage(
                      icon: Icons.key_off,
                      color: Colors.orange,
                      text: t('ai_key_missing'),
                    )
                  else if (state.error != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AiMessage(
                          icon: Icons.error_outline,
                          color: Colors.red,
                          text: '${t('ai_error')}: ${state.error}',
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => ref
                              .read(aiAnalysisProvider(pdbId).notifier)
                              .analyze(protein, locale),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(t('ai_retry')),
                        ),
                      ],
                    )
                  else if (state.analysis != null)
                    _AiResultView(text: state.analysis!).animate().fadeIn()
                  else
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => ref
                            .read(aiAnalysisProvider(pdbId).notifier)
                            .analyze(protein, locale),
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: Text(t('ai_button')),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ).animate().scale(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiMessage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _AiMessage({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: color))),
      ],
    );
  }
}

class _AiResultView extends StatelessWidget {
  final String text;
  const _AiResultView({required this.text});

  @override
  Widget build(BuildContext context) {
    // Render bold **text** markers inline.
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: i.isOdd
            ? const TextStyle(fontWeight: FontWeight.bold)
            : const TextStyle(height: 1.6),
      ));
    }
    return SelectableText.rich(
      TextSpan(children: spans),
      style: const TextStyle(fontSize: 14, height: 1.6),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SequenceViewer extends StatelessWidget {
  final String sequence;
  const _SequenceViewer({required this.sequence});

  @override
  Widget build(BuildContext context) {
    final lines = <String>[];
    for (int i = 0; i < sequence.length; i += 60) {
      lines.add(sequence.substring(i, (i + 60).clamp(0, sequence.length)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.asMap().entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            SizedBox(
              width: 40,
              child: Text('${e.key * 60 + 1}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
            Expanded(
              child: Text(e.value,
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 12, letterSpacing: 1)),
            ),
          ]),
        );
      }).toList(),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  const _SectionCard({required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)),
                ),
                if (action != null) action!,
              ],
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final String retryLabel;
  final VoidCallback onRetry;
  const _ErrorView(
      {required this.error, required this.retryLabel, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 72, color: Colors.red),
            const SizedBox(height: 16),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
