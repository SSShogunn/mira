// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadHistoryAdapter extends TypeAdapter<DownloadHistory> {
  @override
  final int typeId = 1;

  @override
  DownloadHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadHistory(
      url: fields[0] as String,
      filename: fields[1] as String,
      downloadedAt: fields[2] as DateTime,
      status: fields[3] as String,
      filePath: fields[5] as String?,
      errorMessage: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadHistory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.filename)
      ..writeByte(5)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.downloadedAt)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.errorMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
