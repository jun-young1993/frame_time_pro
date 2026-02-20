import 'package:flutter/foundation.dart';

@immutable
class FpsMode {
  const FpsMode._({
    required this.label,
    required this.frameBase,
    required this.fpsReal,
    required this.allowsDropFrame,
  });

  /// UI label (e.g. "29.97").
  final String label;

  /// Integer base used to validate/encode the FF segment.
  final int frameBase;

  /// Real FPS for seconds conversion (e.g. 29.97).
  final double fpsReal;

  /// Whether DF is a valid mode for this FPS.
  final bool allowsDropFrame;

  static const fps23_976 = FpsMode._(
    label: '23.976',
    frameBase: 24,
    fpsReal: 23.976,
    allowsDropFrame: true,
  );
  static const fps24 = FpsMode._(
    label: '24',
    frameBase: 24,
    fpsReal: 24.0,
    allowsDropFrame: false,
  );
  static const fps25 = FpsMode._(
    label: '25',
    frameBase: 25,
    fpsReal: 25.0,
    allowsDropFrame: false,
  );
  static const fps29_97 = FpsMode._(
    label: '29.97',
    frameBase: 30,
    fpsReal: 29.97,
    allowsDropFrame: true,
  );
  static const fps30 = FpsMode._(
    label: '30',
    frameBase: 30,
    fpsReal: 30.0,
    allowsDropFrame: false,
  );

  static const values = <FpsMode>[fps23_976, fps24, fps25, fps29_97, fps30];

  @override
  String toString() => 'FpsMode($label)';

  bool get isDropFrame => allowsDropFrame;
}
