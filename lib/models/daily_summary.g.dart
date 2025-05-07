
part of 'daily_summary.dart';

class DailySummaryAdapter extends TypeAdapter<DailySummary> {
  @override
  final int typeId = 1;

  @override
  DailySummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailySummary(
      date: fields[0] as DateTime,
      timeSpentByLocation: (fields[1] as Map?)?.cast<String, Duration>(),
      travelingTime: fields[2] as Duration?,
      sessionStartTime: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DailySummary obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.timeSpentByLocation)
      ..writeByte(2)
      ..write(obj.travelingTime)
      ..writeByte(3)
      ..write(obj.sessionStartTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
