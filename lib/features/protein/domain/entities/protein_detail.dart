import 'protein.dart';

class ProteinDetail extends Protein {
  final List<ChainInfo> chains;
  final PhysicoChemicalProperties properties;
  final List<String> keywords;

  const ProteinDetail({
    required super.pdbId,
    required super.title,
    required super.organism,
    required super.method,
    super.resolution,
    required super.chainCount,
    required super.releaseDate,
    super.thumbnailUrl,
    required this.chains,
    required this.properties,
    required this.keywords,
  });
}

class ChainInfo {
  final String chainId;
  final String? description;
  final int residueCount;
  final String? sequence;

  const ChainInfo({
    required this.chainId,
    this.description,
    required this.residueCount,
    this.sequence,
  });
}

class PhysicoChemicalProperties {
  final double molecularWeight;
  final double isoelectricPoint;
  final double instabilityIndex;
  final double aliphaticIndex;
  final double gravy;
  final Map<String, double> aminoAcidComposition;

  const PhysicoChemicalProperties({
    required this.molecularWeight,
    required this.isoelectricPoint,
    required this.instabilityIndex,
    required this.aliphaticIndex,
    required this.gravy,
    required this.aminoAcidComposition,
  });

  static PhysicoChemicalProperties compute(String seq) {
    if (seq.isEmpty) {
      return const PhysicoChemicalProperties(
        molecularWeight: 0,
        isoelectricPoint: 7.0,
        instabilityIndex: 40.0,
        aliphaticIndex: 0,
        gravy: 0,
        aminoAcidComposition: {},
      );
    }

    const mw = {
      'A': 89.09, 'R': 174.20, 'N': 132.12, 'D': 133.10, 'C': 121.16,
      'E': 147.13, 'Q': 146.15, 'G': 75.03,  'H': 155.16, 'I': 131.17,
      'L': 131.17, 'K': 146.19, 'M': 149.21, 'F': 165.19, 'P': 115.13,
      'S': 105.09, 'T': 119.12, 'W': 204.23, 'Y': 181.19, 'V': 117.15,
    };
    const hydropathy = {
      'A': 1.8,  'R': -4.5, 'N': -3.5, 'D': -3.5, 'C': 2.5,
      'E': -3.5, 'Q': -3.5, 'G': -0.4, 'H': -3.2, 'I': 4.5,
      'L': 3.8,  'K': -3.9, 'M': 1.9,  'F': 2.8,  'P': -1.6,
      'S': -0.8, 'T': -0.7, 'W': -0.9, 'Y': -1.3, 'V': 4.2,
    };

    double totalMw = 0, totalGravy = 0;
    final count = <String, double>{};
    int valid = 0;

    for (final aa in seq.toUpperCase().split('')) {
      if (mw.containsKey(aa)) {
        totalMw += mw[aa]!;
        totalGravy += hydropathy[aa] ?? 0;
        count[aa] = (count[aa] ?? 0) + 1;
        valid++;
      }
    }

    if (valid == 0) {
      return const PhysicoChemicalProperties(
        molecularWeight: 0, isoelectricPoint: 7.0, instabilityIndex: 40.0,
        aliphaticIndex: 0, gravy: 0, aminoAcidComposition: {},
      );
    }

    final comp = count.map((k, v) => MapEntry(k, v / valid * 100));
    final gravy = totalGravy / valid;
    final a = count['A'] ?? 0;
    final v = count['V'] ?? 0;
    final i = count['I'] ?? 0;
    final l = count['L'] ?? 0;
    final aliphatic = 100 * (a + 2.9 * v + 3.9 * (i + l)) / valid;

    // Rough pI from basic/acidic AA ratio
    final basicAA = (count['K'] ?? 0) + (count['R'] ?? 0) + (count['H'] ?? 0);
    final acidicAA = (count['D'] ?? 0) + (count['E'] ?? 0);
    final pI = (7.0 + (basicAA - acidicAA) / valid * 3.5).clamp(1.0, 13.0);

    // Instability index (simplified Guruprasad)
    final instability = 40.0 + ((count['D'] ?? 0) + (count['E'] ?? 0)) / valid * 20
        - ((count['A'] ?? 0) + (count['V'] ?? 0)) / valid * 10;

    return PhysicoChemicalProperties(
      molecularWeight: totalMw / 1000,
      isoelectricPoint: pI,
      instabilityIndex: instability.clamp(0, 100),
      aliphaticIndex: aliphatic,
      gravy: gravy,
      aminoAcidComposition: comp,
    );
  }
}
