import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/fps_mode.dart';
import '../domain/timecode.dart';
import '../domain/timecode_math.dart';
import 'timecode_calculator_state.dart';

final timecodeCalculatorProvider =
    StateNotifierProvider<TimecodeCalculatorNotifier, TimecodeCalculatorState>(
  (ref) => TimecodeCalculatorNotifier(),
);

class TimecodeCalculatorNotifier extends StateNotifier<TimecodeCalculatorState> {
  TimecodeCalculatorNotifier() : super(TimecodeCalculatorState.initial) {
    _recompute(shouldAnimate: false);
  }

  void setConversionMode(ConversionMode mode) {
    state = state.copyWith(conversionMode: mode);
    _recompute(shouldAnimate: true);
  }

  void setFpsMode(FpsMode fpsMode) {
    final old = state;
    final nextDropFrame = fpsMode.allowsDropFrame ? old.isDropFrame : false;
    final nextA = _revalidateTimecodeWithModeChange(
      old.inputA,
      fpsMode,
      nextDropFrame,
    );

    state = old.copyWith(
      fpsMode: fpsMode,
      isDropFrame: nextDropFrame,
      inputA: nextA,
    );
    _recompute(shouldAnimate: true);
  }

  void setDropFrame(bool isDropFrame) {
    final old = state;
    if (isDropFrame && !old.fpsMode.allowsDropFrame) return;
    final nextA = _revalidateTimecodeWithModeChange(
      old.inputA,
      old.fpsMode,
      isDropFrame,
    );
    state = old.copyWith(isDropFrame: isDropFrame, inputA: nextA);
    _recompute(shouldAnimate: true);
  }

  void setInputSegments(
    TimecodeSegments segments, {
    required bool isCommit,
    bool shouldAnimateResult = false,
  }) {
    final nextInput = _validateTimecodeForDisplay(
      segments,
      state.fpsMode,
      state.isDropFrame,
      isCommit: isCommit,
    );
    state = state.copyWith(inputA: nextInput);
    _recompute(shouldAnimate: shouldAnimateResult);
  }

  void setFrameInput(String value) {
    state = state.copyWith(frameInput: value);
    _recompute(shouldAnimate: false);
  }

  void setSecondInput(String value) {
    state = state.copyWith(secondInput: value);
    _recompute(shouldAnimate: false);
  }

  TimecodeInputModel _validateTimecodeForDisplay(
    TimecodeSegments segments,
    FpsMode fpsMode,
    bool isDropFrame, {
    required bool isCommit,
  }) {
    final base = TimecodeInputModel(segments: segments, issue: null);
    final treatIncompleteAsIssue = isCommit && base.hasAnyDigits;
    final validation = validateTimecode(
      segments: segments,
      fpsMode: fpsMode,
      isDropFrame: isDropFrame,
      treatIncompleteAsIssue: treatIncompleteAsIssue,
    );
    if (validation.issue == null) return base.copyWith(issue: null);
    return base.copyWith(issue: validation.issue);
  }

  TimecodeInputModel _revalidateTimecodeWithModeChange(
    TimecodeInputModel input,
    FpsMode fpsMode,
    bool isDropFrame,
  ) {
    if (!input.hasAnyDigits) return input.copyWith(issue: null);
    final validation = validateTimecode(
      segments: input.segments,
      fpsMode: fpsMode,
      isDropFrame: isDropFrame,
      treatIncompleteAsIssue: false,
    );
    if (validation.issue == null) return input.copyWith(issue: null);
    return input.copyWith(
      issue: TimecodeIssue(
        message: validation.issue!.message,
        severity: TimecodeIssueSeverity.warning,
      ),
    );
  }

  TimecodeValidation _validateTimecodeForCompute(
    TimecodeSegments segments,
    FpsMode fpsMode,
    bool isDropFrame,
  ) {
    return validateTimecode(
      segments: segments,
      fpsMode: fpsMode,
      isDropFrame: isDropFrame,
      treatIncompleteAsIssue: true,
    );
  }

  void _recompute({required bool shouldAnimate}) {
    final old = state;
    final mode = old.conversionMode;
    final fps = old.fpsMode;
    final df = old.isDropFrame;
    final fpsReal = fps.fpsReal;

    String display = '—';
    bool valid = false;

    switch (mode) {
      case ConversionMode.frameToTimecode:
        final n = int.tryParse(old.frameInput.trim());
        if (n != null && n >= 0) {
          final tc = TimecodeMath.fromFrameNumber(
            frameNumber: n,
            fpsMode: fps,
            isDropFrame: df,
          );
          display = tc.format(isDropFrame: df);
          valid = true;
        }
        break;

      case ConversionMode.timecodeToFrame:
        final v = _validateTimecodeForCompute(old.inputA.segments, fps, df);
        if (v.isValid) {
          final frames = TimecodeMath.toFrameNumber(
            timecode: v.timecode!,
            fpsMode: fps,
            isDropFrame: df,
          );
          display = frames.toString();
          valid = true;
        }
        break;

      case ConversionMode.timecodeToSecond:
        final v = _validateTimecodeForCompute(old.inputA.segments, fps, df);
        if (v.isValid) {
          final frames = TimecodeMath.toFrameNumber(
            timecode: v.timecode!,
            fpsMode: fps,
            isDropFrame: df,
          );
          final sec = TimecodeMath.framesToSeconds(frames, fpsReal);
          display = sec.toStringAsFixed(sec.truncateToDouble() == sec ? 0 : 3);
          valid = true;
        }
        break;

      case ConversionMode.secondToTimecode:
        final sec = double.tryParse(old.secondInput.trim());
        if (sec != null && sec >= 0) {
          final frames = TimecodeMath.secondsToFrames(sec, fpsReal);
          final tc = TimecodeMath.fromFrameNumber(
            frameNumber: frames,
            fpsMode: fps,
            isDropFrame: df,
          );
          display = tc.format(isDropFrame: df);
          valid = true;
        }
        break;

      case ConversionMode.secondToFrame:
        final sec = double.tryParse(old.secondInput.trim());
        if (sec != null && sec >= 0) {
          final frames = TimecodeMath.secondsToFrames(sec, fpsReal);
          display = frames.toString();
          valid = true;
        }
        break;

      case ConversionMode.frameToSecond:
        final n = int.tryParse(old.frameInput.trim());
        if (n != null && n >= 0) {
          final sec = TimecodeMath.framesToSeconds(n, fpsReal);
          display = sec.toStringAsFixed(sec.truncateToDouble() == sec ? 0 : 3);
          valid = true;
        }
        break;
    }

    final nextResult = TimecodeResultModel(
      display: display,
      isValid: valid,
      isNegative: false,
    );
    final shouldBump = shouldAnimate && valid && nextResult.display != old.result.display;
    state = old.copyWith(
      result: nextResult,
      resultAnimationNonce: shouldBump ? old.resultAnimationNonce + 1 : old.resultAnimationNonce,
    );
  }
}
