import 'package:hive_flutter/hive_flutter.dart';

import '../domain/conversion_record.dart';

class HistoryRepository {
  static const _boxName = 'conversion_history';

  Box<ConversionRecord> get _box => Hive.box<ConversionRecord>(_boxName);

  /// 앱 시작 시 한 번 호출. 어댑터 등록 + 박스 열기.
  static Future<void> init() async {
    Hive.registerAdapter(ConversionRecordAdapter());
    await Hive.openBox<ConversionRecord>(_boxName);
  }

  Future<void> save(ConversionRecord record) async {
    await _box.add(record);
  }

  /// 최신순으로 반환.
  List<ConversionRecord> getAll() {
    return _box.values.toList().reversed.toList();
  }

  Future<void> delete(ConversionRecord record) async {
    await record.delete();
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
