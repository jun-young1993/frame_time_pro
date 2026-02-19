import 'fps_mode.dart';
import 'timecode.dart';

class TimecodeMath {
  const TimecodeMath._();

  static int toFrameNumber({
    required Timecode timecode,
    required FpsMode fpsMode,
    required bool isDropFrame,
  }) {
    final base = fpsMode.frameBase;

    if (!isDropFrame) {
      return (((timecode.hours * 60 + timecode.minutes) * 60 + timecode.seconds) * base) + timecode.frames;
    }

    // 29.97 DF, 30-base label with dropped frame numbers.
    // Reference: http://www.andrewduncan.net/timecodes/
    final totalMinutes = 60 * timecode.hours + timecode.minutes;
    final nominal30FrameNumber =
        (108000 * timecode.hours) + (1800 * timecode.minutes) + (30 * timecode.seconds) + timecode.frames;
    final dropped = 2 * (totalMinutes - (totalMinutes ~/ 10));
    return nominal30FrameNumber - dropped;
  }

  static Timecode fromFrameNumber({
    required int frameNumber,
    required FpsMode fpsMode,
    required bool isDropFrame,
  }) {
    final base = fpsMode.frameBase;

    if (!isDropFrame) {
      final frames = frameNumber % base;
      final totalSeconds = frameNumber ~/ base;
      final seconds = totalSeconds % 60;
      final totalMinutes = totalSeconds ~/ 60;
      final minutes = totalMinutes % 60;
      final hours = totalMinutes ~/ 60;
      return Timecode(hours: hours, minutes: minutes, seconds: seconds, frames: frames);
    }

    // 29.97 DF conversion from frame number back to DF timecode.
    // Reference: http://www.andrewduncan.net/timecodes/
    var n = frameNumber;
    final d = n ~/ 17982;
    final m = n % 17982;
    final extraMinutes = m < 2 ? 0 : ((m - 2) ~/ 1798);
    n += (18 * d) + (2 * extraMinutes);

    final frames = n % 30;
    final totalSeconds = n ~/ 30;
    final seconds = totalSeconds % 60;
    final totalMinutes = totalSeconds ~/ 60;
    final minutes = totalMinutes % 60;
    // Do not wrap hours in a calculator context.
    final hours = totalMinutes ~/ 60;
    return Timecode(hours: hours, minutes: minutes, seconds: seconds, frames: frames);
  }

  /// Convert frame count to seconds at given real FPS.
  static double framesToSeconds(int frames, double fpsReal) => frames / fpsReal;

  /// Convert seconds to frame count at given real FPS (rounded).
  static int secondsToFrames(double seconds, double fpsReal) => (seconds * fpsReal).round();
}

