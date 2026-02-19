import 'package:flutter/foundation.dart';

import 'fps_mode.dart';

@immutable
class Timecode {
  const Timecode({
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.frames,
  });

  final int hours;
  final int minutes;
  final int seconds;
  final int frames;

  String format({required bool isDropFrame}) {
    final sep = isDropFrame ? ';' : ':';
    return '${_pad2(hours)}:${_pad2(minutes)}:${_pad2(seconds)}$sep${_pad2(frames)}';
  }

  static String _pad2(int value) => value.abs().toString().padLeft(2, '0');
}

@immutable
class TimecodeSegments {
  const TimecodeSegments({
    required this.hh,
    required this.mm,
    required this.ss,
    required this.ff,
  });

  final String hh;
  final String mm;
  final String ss;
  final String ff;

  static const empty = TimecodeSegments(hh: '', mm: '', ss: '', ff: '');

  bool get isComplete => hh.length == 2 && mm.length == 2 && ss.length == 2 && ff.length == 2;

  String display({required bool isDropFrame}) {
    final sep = isDropFrame ? ';' : ':';
    return '${_disp2(hh)}:${_disp2(mm)}:${_disp2(ss)}$sep${_disp2(ff)}';
  }

  TimecodeSegments copyWith({
    String? hh,
    String? mm,
    String? ss,
    String? ff,
  }) {
    return TimecodeSegments(
      hh: hh ?? this.hh,
      mm: mm ?? this.mm,
      ss: ss ?? this.ss,
      ff: ff ?? this.ff,
    );
  }

  static String _disp2(String value) => value.padLeft(2, '0');
}

enum TimecodeIssueSeverity { warning, error }

@immutable
class TimecodeIssue {
  const TimecodeIssue({required this.message, required this.severity});

  final String message;
  final TimecodeIssueSeverity severity;
}

@immutable
class TimecodeValidation {
  const TimecodeValidation({
    required this.timecode,
    required this.issue,
  });

  final Timecode? timecode;
  final TimecodeIssue? issue;

  bool get isValid => timecode != null && issue == null;
}

TimecodeValidation validateTimecode({
  required TimecodeSegments segments,
  required FpsMode fpsMode,
  required bool isDropFrame,
  required bool treatIncompleteAsIssue,
}) {
  if (!segments.isComplete) {
    return TimecodeValidation(
      timecode: null,
      issue: treatIncompleteAsIssue
          ? const TimecodeIssue(
              message: 'Incomplete timecode.',
              severity: TimecodeIssueSeverity.error,
            )
          : null,
    );
  }

  final hours = int.tryParse(segments.hh);
  final minutes = int.tryParse(segments.mm);
  final seconds = int.tryParse(segments.ss);
  final frames = int.tryParse(segments.ff);

  if (hours == null || minutes == null || seconds == null || frames == null) {
    return const TimecodeValidation(
      timecode: null,
      issue: TimecodeIssue(message: 'Invalid digits.', severity: TimecodeIssueSeverity.error),
    );
  }

  if (minutes < 0 || minutes > 59) {
    return const TimecodeValidation(
      timecode: null,
      issue: TimecodeIssue(message: 'Minutes must be 00–59.', severity: TimecodeIssueSeverity.error),
    );
  }
  if (seconds < 0 || seconds > 59) {
    return const TimecodeValidation(
      timecode: null,
      issue: TimecodeIssue(message: 'Seconds must be 00–59.', severity: TimecodeIssueSeverity.error),
    );
  }

  final maxFrame = fpsMode.frameBase - 1;
  if (frames < 0 || frames > maxFrame) {
    return TimecodeValidation(
      timecode: null,
      issue: TimecodeIssue(
        message: 'Frames must be 00–${maxFrame.toString().padLeft(2, '0')}.',
        severity: TimecodeIssueSeverity.error,
      ),
    );
  }

  final tc = Timecode(hours: hours, minutes: minutes, seconds: seconds, frames: frames);

  if (isDropFrame) {
    if (!fpsMode.allowsDropFrame) {
      return const TimecodeValidation(
        timecode: null,
        issue: TimecodeIssue(message: 'Drop-frame not supported for this FPS.', severity: TimecodeIssueSeverity.error),
      );
    }

    // DF legality (29.97 only in current scope): illegal labels at minute start except each 10th minute.
    final totalMinutes = hours * 60 + minutes;
    final isIllegalMinuteStart = seconds == 0 && (frames == 0 || frames == 1) && (totalMinutes % 10 != 0);
    if (isIllegalMinuteStart) {
      return TimecodeValidation(
        timecode: null,
        issue: TimecodeIssue(
          message: 'Illegal DF label at minute start (use ;00 or ;01 only every 10th minute).',
          severity: TimecodeIssueSeverity.error,
        ),
      );
    }
  }

  return TimecodeValidation(timecode: tc, issue: null);
}

