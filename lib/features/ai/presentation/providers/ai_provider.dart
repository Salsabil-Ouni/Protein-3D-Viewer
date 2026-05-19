import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../protein/domain/entities/protein_detail.dart';

class AiAnalysisState {
  final bool isLoading;
  final String? analysis;
  final String? error;

  const AiAnalysisState({this.isLoading = false, this.analysis, this.error});
}

class AiAnalysisNotifier extends StateNotifier<AiAnalysisState> {
  AiAnalysisNotifier() : super(const AiAnalysisState());

  Future<void> analyze(ProteinDetail protein, String locale) async {
    if (ApiConstants.geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      state = const AiAnalysisState(error: 'KEY_MISSING');
      return;
    }

    state = const AiAnalysisState(isLoading: true);
    try {
      final prompt = _buildPrompt(protein, locale);

      final dio = Dio();
      final response = await dio.post(
        '${ApiConstants.geminiUrl}?key=${ApiConstants.geminiApiKey}',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 800,
          },
        },
      );

      final text = response.data['candidates'][0]['content']['parts'][0]['text'] as String;
      state = AiAnalysisState(analysis: text.trim());
    } on DioException catch (e) {
      final msg = e.response?.data?['error']?['message'] ?? e.message ?? 'Network error';
      state = AiAnalysisState(error: msg);
    } catch (e) {
      state = AiAnalysisState(error: e.toString());
    }
  }

  void reset() => state = const AiAnalysisState();

  String _buildPrompt(ProteinDetail p, String locale) {
    final props = p.properties;
    final kwStr = p.keywords.take(5).join(', ');
    final chainSummary = p.chains
        .take(3)
        .map((c) => 'Chain ${c.chainId} (${c.residueCount} residues)')
        .join(', ');

    if (locale == 'fr') {
      return '''
Vous êtes un expert en biochimie et biologie structurale. Analysez cette protéine et répondez en français de façon claire et pédagogique.

Protéine: ${p.pdbId} — ${p.title}
Organisme: ${p.organism}
Méthode expérimentale: ${p.method}${p.resolution != null ? ' (résolution: ${p.resolution!.toStringAsFixed(2)} Å)' : ''}
Chaînes: $chainSummary
Mots-clés: $kwStr

Propriétés physicochimiques:
- Poids moléculaire: ${props.molecularWeight.toStringAsFixed(1)} kDa
- Point isoélectrique (pI): ${props.isoelectricPoint.toStringAsFixed(2)}
- Indice d'instabilité: ${props.instabilityIndex.toStringAsFixed(1)} (${props.instabilityIndex > 40 ? 'Instable' : 'Stable'})
- Indice aliphatique: ${props.aliphaticIndex.toStringAsFixed(1)}
- GRAVY: ${props.gravy.toStringAsFixed(3)}

Fournissez:
1. **Fonction biologique** : rôle principal de cette protéine dans l'organisme
2. **Caractéristiques structurales** : que révèlent les chaînes et la méthode expérimentale ?
3. **Propriétés physicochimiques** : interprétation du pI, stabilité, hydrophobicité (GRAVY)
4. **Pertinence médicale/industrielle** : applications, maladies associées si applicable
5. **Points remarquables** : faits intéressants sur cette protéine

Répondez en 5 paragraphes structurés, de façon scientifique mais accessible.
''';
    }

    return '''
You are an expert biochemist and structural biologist. Analyze this protein and provide a clear, educational response.

Protein: ${p.pdbId} — ${p.title}
Organism: ${p.organism}
Experimental method: ${p.method}${p.resolution != null ? ' (resolution: ${p.resolution!.toStringAsFixed(2)} Å)' : ''}
Chains: $chainSummary
Keywords: $kwStr

Physicochemical properties:
- Molecular weight: ${props.molecularWeight.toStringAsFixed(1)} kDa
- Isoelectric point (pI): ${props.isoelectricPoint.toStringAsFixed(2)}
- Instability index: ${props.instabilityIndex.toStringAsFixed(1)} (${props.instabilityIndex > 40 ? 'Unstable' : 'Stable'})
- Aliphatic index: ${props.aliphaticIndex.toStringAsFixed(1)}
- GRAVY: ${props.gravy.toStringAsFixed(3)}

Provide:
1. **Biological function**: main role of this protein in the organism
2. **Structural characteristics**: what do the chains and experimental method reveal?
3. **Physicochemical properties**: interpretation of pI, stability, hydrophobicity (GRAVY)
4. **Medical/industrial relevance**: applications, associated diseases if applicable
5. **Notable facts**: interesting facts about this protein

Respond in 5 structured paragraphs, scientifically accurate but accessible.
''';
  }
}

/// Family provider — one AI state per PDB ID so analyses are cached per protein.
final aiAnalysisProvider =
    StateNotifierProvider.family<AiAnalysisNotifier, AiAnalysisState, String>(
  (ref, pdbId) => AiAnalysisNotifier(),
);
