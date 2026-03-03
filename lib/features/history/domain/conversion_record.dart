import 'package:hive_flutter/hive_flutter.dart';

/// 변환 기록 모델.
/// Hive 어댑터를 수동으로 작성하여 build_runner 의존성을 제거.
class ConversionRecord extends HiveObject {
  ConversionRecord({
    required this.conversionType,
    required this.inputValue,
    required this.outputValue,
    required this.timestamp,
  });

  /// 변환 타입 레이블 (예: "Frame → TC")
  String conversionType;

  /// 사용자가 입력한 값
  String inputValue;

  /// 계산된 결과값
  String outputValue;

  /// 저장 시각
  DateTime timestamp;

  static const int typeId = 0;
}

class ConversionRecordAdapter extends TypeAdapter<ConversionRecord> {
  @override
  final int typeId = ConversionRecord.typeId;

  @override
  ConversionRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversionRecord(
      conversionType: fields[0] as String,
      inputValue: fields[1] as String,
      outputValue: fields[2] as String,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ConversionRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.conversionType)
      ..writeByte(1)
      ..write(obj.inputValue)
      ..writeByte(2)
      ..write(obj.outputValue)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversionRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
