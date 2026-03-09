// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambience_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AmbienceModelAdapter extends TypeAdapter<AmbienceModel> {
  @override
  final int typeId = 0;

  @override
  AmbienceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AmbienceModel(
      id: fields[0] as String,
      title: fields[1] as String,
      tag: fields[2] as String,
      durationMinutes: fields[3] as int,
      description: fields[4] as String,
      imagePath: fields[5] as String,
      audioPath: fields[6] as String,
      sensoryRecipes: (fields[7] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AmbienceModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.tag)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.audioPath)
      ..writeByte(7)
      ..write(obj.sensoryRecipes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmbienceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
