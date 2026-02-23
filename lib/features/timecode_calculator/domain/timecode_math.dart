import 'package:timecode/timecode.dart' as tc;

import 'fps_mode.dart';
import 'timecode.dart';

class TimecodeMath {
  const TimecodeMath._();

  static tc.TimecodeFramerate _framerate(FpsMode fpsMode, bool isDropFrame) =>
      tc.TimecodeFramerate(fpsMode.fpsReal, forceNonDropFrame: !isDropFrame);

  static int toFrameNumber({
    required Timecode timecode,
    required FpsMode fpsMode,
    required bool isDropFrame,
  }) {
    final framerate = _framerate(fpsMode, isDropFrame);
    final sep = isDropFrame ? ';' : ':';
    final tcStr =
        '${_p(timecode.hours)}:${_p(timecode.minutes)}:${_p(timecode.seconds)}$sep${_p(timecode.frames)}';

    return tc.Timecode.parseToFrames(tcStr, framerate: framerate);
  }

  static Timecode fromFrameNumber({
    required int frameNumber,
    required FpsMode fpsMode,
    required bool isDropFrame,
  }) {
    final pkgTc = tc.Timecode(
      framerate: _framerate(fpsMode, isDropFrame),
      startFrames: frameNumber,
    );
    return Timecode(
      hours: pkgTc.hh,
      minutes: pkgTc.mm,
      seconds: pkgTc.ss,
      frames: pkgTc.ff,
    );
  }

  /// Convert frame count to seconds at given real FPS.
  static double framesToSeconds(int frames, double fpsReal) =>
      frames / tc.TimecodeFramerate(fpsReal, forceNonDropFrame: true).fps;

  /// Convert seconds to frame count at given real FPS.
  static int secondsToFrames(double seconds, double fpsReal) =>
      tc.TimecodeFramerate(fpsReal, forceNonDropFrame: true)
          .realSecondsToFrames(seconds);

  static String _p(int n) => n.toString().padLeft(2, '0');
}
