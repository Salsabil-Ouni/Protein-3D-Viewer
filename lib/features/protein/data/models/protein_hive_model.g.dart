// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protein_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProteinHiveModelAdapter extends TypeAdapter<ProteinHiveModel> {
  @override
  final int typeId = 0;

  @override
  ProteinHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProteinHiveModel(
      pdbId: fields[0] as String,
      title: fields[1] as String,
      organism: fields[2] as String,
      method: fields[3] as String,
      resolution: fields[4] as double?,
      chainCount: fields[5] as int,
      releaseDate: fields[6] as String,
      thumbnailUrl: fields[7] as String?,
      savedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProteinHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.pdbId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.organism)
      ..writeByte(3)
      ..write(obj.method)
      ..writeByte(4)
      ..write(obj.resolution)
      ..writeByte(5)
      ..write(obj.chainCount)
      ..writeByte(6)
      ..write(obj.releaseDate)
      ..writeByte(7)
      ..write(obj.thumbnailUrl)
      ..writeByte(8)
      ..write(obj.savedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProteinHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
