class Protein {
  final String pdbId;
  final String title;
  final String organism;
  final String method;
  final double? resolution;
  final int chainCount;
  final String releaseDate;
  final String? thumbnailUrl;

  const Protein({
    required this.pdbId,
    required this.title,
    required this.organism,
    required this.method,
    this.resolution,
    required this.chainCount,
    required this.releaseDate,
    this.thumbnailUrl,
  });
}
