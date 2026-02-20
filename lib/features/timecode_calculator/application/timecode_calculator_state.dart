import 'package:flutter/foundation.dart';

import '../domain/fps_mode.dart';
import '../domain/timecode.dart';

enum TimecodeInputSlot { a }

enum TimecodeSegment { hh, mm, ss, ff }

/// Conversion direction: input → output.
enum ConversionMode {
  frameToTimecode,
  timecodeToFrame,
  timecodeToSecond,
  secondToTimecode,
  secondToFrame,
  frameToSecond,
}

extension ConversionModeX on ConversionMode {
  String get label => switch (this) {
    ConversionMode.frameToTimecode => 'Frame → TC',
    ConversionMode.timecodeToFrame => 'TC → Frame',
    ConversionMode.timecodeToSecond => 'TC → Sec',
    ConversionMode.secondToTimecode => 'Sec → TC',
    ConversionMode.secondToFrame => 'Sec → Frame',
    ConversionMode.frameToSecond => 'Frame → Sec',
  };

  bool get inputIsTimecode =>
      this == ConversionMode.timecodeToFrame ||
      this == ConversionMode.timecodeToSecond;
  bool get inputIsFrame =>
      this == ConversionMode.frameToTimecode ||
      this == ConversionMode.frameToSecond;
  bool get inputIsSecond =>
      this == ConversionMode.secondToTimecode ||
      this == ConversionMode.secondToFrame;
  bool get outputIsTimecode =>
      this == ConversionMode.frameToTimecode ||
      this == ConversionMode.secondToTimecode;
  bool get outputIsFrame =>
      this == ConversionMode.timecodeToFrame ||
      this == ConversionMode.secondToFrame;
  bool get outputIsSecond =>
      this == ConversionMode.timecodeToSecond ||
      this == ConversionMode.frameToSecond;
}

@immutable
class TimecodeInputModel {
  const TimecodeInputModel({required this.segments, required this.issue});

  final TimecodeSegments segments;
  final TimecodeIssue? issue;

  bool get hasAnyDigits =>
      segments.hh.isNotEmpty ||
      segments.mm.isNotEmpty ||
      segments.ss.isNotEmpty ||
      segments.ff.isNotEmpty;

  TimecodeInputModel copyWith({
    TimecodeSegments? segments,
    TimecodeIssue? issue,
  }) {
    return TimecodeInputModel(
      segments: segments ?? this.segments,
      issue: issue,
    );
  }

  static const empty = TimecodeInputModel(
    segments: TimecodeSegments.empty,
    issue: null,
  );
}

@immutable
class TimecodeResultModel {
  const TimecodeResultModel({
    required this.display,
    required this.isValid,
    required this.isNegative,
  });

  final String display;
  final bool isValid;
  final bool isNegative;

  static const invalid = TimecodeResultModel(
    display: '—',
    isValid: false,
    isNegative: false,
  );
}

@immutable
class TimecodeCalculatorState {
  const TimecodeCalculatorState({
    required this.fpsMode,
    required this.isDropFrame,
    required this.conversionMode,
    required this.inputA,
    required this.frameInput,
    required this.secondInput,
    required this.result,
    required this.resultAnimationNonce,
  });

  final FpsMode fpsMode;
  final bool isDropFrame;
  final ConversionMode conversionMode;
  final TimecodeInputModel inputA;
  final String frameInput;
  final String secondInput;
  final TimecodeResultModel result;
  final int resultAnimationNonce;

  String get statusFpsLabel =>
      'FPS: ${fpsMode.label}${isDropFrame ? ' DF' : ' NDF'}';

  String get statusModeLabel => conversionMode.label;

  TimecodeCalculatorState copyWith({
    FpsMode? fpsMode,
    bool? isDropFrame,
    ConversionMode? conversionMode,
    TimecodeInputModel? inputA,
    String? frameInput,
    String? secondInput,
    TimecodeResultModel? result,
    int? resultAnimationNonce,
  }) {
    return TimecodeCalculatorState(
      fpsMode: fpsMode ?? this.fpsMode,
      isDropFrame: isDropFrame ?? this.isDropFrame,
      conversionMode: conversionMode ?? this.conversionMode,
      inputA: inputA ?? this.inputA,
      frameInput: frameInput ?? this.frameInput,
      secondInput: secondInput ?? this.secondInput,
      result: result ?? this.result,
      resultAnimationNonce: resultAnimationNonce ?? this.resultAnimationNonce,
    );
  }

  static final initial = TimecodeCalculatorState(
    fpsMode: FpsMode.fps29_97,
    isDropFrame: FpsMode.fps29_97.allowsDropFrame,
    conversionMode: ConversionMode.frameToTimecode,
    inputA: TimecodeInputModel.empty,
    frameInput: '',
    secondInput: '',
    result: TimecodeResultModel.invalid,
    resultAnimationNonce: 0,
  );
}
