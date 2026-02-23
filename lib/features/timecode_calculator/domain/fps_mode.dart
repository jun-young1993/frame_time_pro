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
    allowsDropFrame: false,
  );
  static const fps23_98 = FpsMode._(
    label: '23.98',
    frameBase: 24,
    fpsReal: 23.976,
    allowsDropFrame: false,
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
  static const fps50 = FpsMode._(
    label: '50',
    frameBase: 50,
    fpsReal: 50.0,
    allowsDropFrame: false,
  );
  static const fps59_94 = FpsMode._(
    label: '59.94',
    frameBase: 60,
    fpsReal: 59.94,
    allowsDropFrame: true,
  );
  static const fps60 = FpsMode._(
    label: '60',
    frameBase: 60,
    fpsReal: 60.0,
    allowsDropFrame: false,
  );
  static const fps1000 = FpsMode._(
    label: '1000',
    frameBase: 1000,
    fpsReal: 1000.0,
    allowsDropFrame: false,
  );

  static const values = <FpsMode>[
    fps23_976, fps23_98, fps24, fps25, fps29_97, fps30, fps50, fps59_94, fps60, fps1000,
  ];

  @override
  String toString() => 'FpsMode($label)';

  bool get isDropFrame => allowsDropFrame;
}
