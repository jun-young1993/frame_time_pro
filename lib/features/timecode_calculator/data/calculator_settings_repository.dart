import 'package:hive_flutter/hive_flutter.dart';

import '../application/timecode_calculator_state.dart';
import '../domain/fps_mode.dart';

class CalculatorSettingsRepository {
  static const _boxName = 'calculator_settings';
  static const _keyFpsMode = 'fps_mode';
  static const _keyDropFrame = 'is_drop_frame';
  static const _keyConversionMode = 'conversion_mode';

  Box get _box => Hive.box(_boxName);

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  FpsMode loadFpsMode() {
    final label = _box.get(_keyFpsMode) as String?;
    if (label == null) return FpsMode.fps29_97;
    return FpsMode.values.firstWhere(
      (m) => m.label == label,
      orElse: () => FpsMode.fps29_97,
    );
  }

  bool loadDropFrame() => _box.get(_keyDropFrame) as bool? ?? true;

  ConversionMode loadConversionMode() {
    final name = _box.get(_keyConversionMode) as String?;
    if (name == null) return ConversionMode.frameToTimecode;
    return ConversionMode.values.firstWhere(
      (m) => m.name == name,
      orElse: () => ConversionMode.frameToTimecode,
    );
  }

  void saveFpsMode(FpsMode mode) => _box.put(_keyFpsMode, mode.label);
  void saveDropFrame(bool value) => _box.put(_keyDropFrame, value);
  void saveConversionMode(ConversionMode mode) =>
      _box.put(_keyConversionMode, mode.name);
}
