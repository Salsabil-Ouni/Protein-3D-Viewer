import '../../domain/entities/protein.dart';
import '../../domain/entities/protein_detail.dart';

class ProteinModel extends Protein {
  const ProteinModel({
    required super.pdbId,
    required super.title,
    required super.organism,
    required super.method,
    super.resolution,
    required super.chainCount,
    required super.releaseDate,
    super.thumbnailUrl,
  });

  factory ProteinModel.fromEntryJson(Map<String, dynamic> json, String pdbId) {
    final struct = json['struct'] as Map<String, dynamic>? ?? {};
    final exptl = (json['exptl'] as List?)?.firstOrNull as Map<String, dynamic>? ?? {};
    final refine = (json['refine'] as List?)?.firstOrNull as Map<String, dynamic>? ?? {};
    final rcsb = json['rcsb_entry_info'] as Map<String, dynamic>? ?? {};

    String organism = 'Unknown';
    final srcList = json['rcsb_entity_source_organism'] as List?;
    if (srcList != null && srcList.isNotEmpty) {
      organism = (srcList.first as Map<String, dynamic>)['ncbi_scientific_name'] ?? 'Unknown';
    }

    return ProteinModel(
      pdbId: pdbId.toUpperCase(),
      title: struct['title'] ?? 'Unknown',
      organism: organism,
      method: exptl['method'] ?? 'Unknown',
      resolution: (refine['ls_d_res_high'] as num?)?.toDouble(),
      chainCount: (rcsb['deposited_polymer_entity_instance_count'] as num?)?.toInt() ?? 1,
      releaseDate: (json['rcsb_accession_info']?['initial_release_date'] as String? ?? '').split('T').first,
      thumbnailUrl:
          'https://cdn.rcsb.org/images/structures/${pdbId.toLowerCase()}_model-1.jpeg',
    );
  }
}

class ProteinDetailModel extends ProteinDetail {
  const ProteinDetailModel({
    required super.pdbId,
    required super.title,
    required super.organism,
    required super.method,
    super.resolution,
    required super.chainCount,
    required super.releaseDate,
    super.thumbnailUrl,
    required super.chains,
    required super.properties,
    required super.keywords,
  });

  factory ProteinDetailModel.fromEntryAndEntities(
    Map<String, dynamic> entry,
    String pdbId,
    List<Map<String, dynamic>> entities,
  ) {
    final base = ProteinModel.fromEntryJson(entry, pdbId);

    // Build chains from polymer entities
    final chains = <ChainInfo>[];
    String? firstSeq;

    for (final entity in entities) {
      final poly = entity['entity_poly'] as Map<String, dynamic>? ?? {};
      final entityInfo = entity['rcsb_polymer_entity'] as Map<String, dynamic>? ?? {};

      final strandIds = (poly['pdbx_strand_id'] as String? ?? '').split(',');
      final residueCount = (poly['rcsb_sample_sequence_length'] as num?)?.toInt() ?? 0;
      final sequence = poly['pdbx_seq_one_letter_code_can'] as String?;
      final description = entityInfo['pdbx_description'] as String?;

      firstSeq ??= sequence;

      for (final chainId in strandIds) {
        final id = chainId.trim();
        if (id.isNotEmpty) {
          chains.add(ChainInfo(
            chainId: id,
            description: description,
            residueCount: residueCount,
            sequence: sequence,
          ));
        }
      }
    }

    // Keywords
    final keywords = <String>[];
    final kw = entry['struct_keywords'];
    if (kw != null) {
      final pdbxKw = kw['pdbx_keywords'] as String?;
      final textKw = kw['text'] as String?;
      if (pdbxKw != null && pdbxKw.isNotEmpty) keywords.add(pdbxKw);
      if (textKw != null) {
        keywords.addAll(textKw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
      }
    }

    final props = PhysicoChemicalProperties.compute(firstSeq ?? '');

    return ProteinDetailModel(
      pdbId: base.pdbId,
      title: base.title,
      organism: base.organism,
      method: base.method,
      resolution: base.resolution,
      chainCount: base.chainCount,
      releaseDate: base.releaseDate,
      thumbnailUrl: base.thumbnailUrl,
      chains: chains.isEmpty
          ? [const ChainInfo(chainId: 'A', residueCount: 0)]
          : chains,
      properties: props,
      keywords: keywords,
    );
  }
}
