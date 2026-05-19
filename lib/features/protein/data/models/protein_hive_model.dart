import 'package:hive/hive.dart';

part 'protein_hive_model.g.dart';

@HiveType(typeId: 0)
class ProteinHiveModel extends HiveObject {
  @HiveField(0)
  final String pdbId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String organism;

  @HiveField(3)
  final String method;

  @HiveField(4)
  final double? resolution;

  @HiveField(5)
  final int chainCount;

  @HiveField(6)
  final String releaseDate;

  @HiveField(7)
  final String? thumbnailUrl;

  @HiveField(8)
  final DateTime savedAt;

  ProteinHiveModel({
    required this.pdbId,
    required this.title,
    required this.organism,
    required this.method,
    this.resolution,
    required this.chainCount,
    required this.releaseDate,
    this.thumbnailUrl,
    required this.savedAt,
  });
}
