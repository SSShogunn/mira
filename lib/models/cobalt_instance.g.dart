// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cobalt_instance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CobaltInstanceAdapter extends TypeAdapter<CobaltInstance> {
  @override
  final int typeId = 0;

  @override
  CobaltInstance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CobaltInstance(
      name: fields[0] as String,
      url: fields[1] as String,
      authEnabled: fields[2] as bool,
      apiKey: fields[3] as String?,
      isDefault: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CobaltInstance obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.authEnabled)
      ..writeByte(3)
      ..write(obj.apiKey)
      ..writeByte(4)
      ..write(obj.isDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CobaltInstanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
