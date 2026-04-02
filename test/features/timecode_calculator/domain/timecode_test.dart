import 'package:flutter_test/flutter_test.dart';
import 'package:frame_time_pro/features/timecode_calculator/domain/fps_mode.dart';
import 'package:frame_time_pro/features/timecode_calculator/domain/timecode.dart';

TimecodeSegments _seg(String hh, String mm, String ss, String ff) =>
    TimecodeSegments(hh: hh, mm: mm, ss: ss, ff: ff);

TimecodeValidation _validate(
  TimecodeSegments segments, {
  FpsMode fpsMode = FpsMode.fps29_97,
  bool isDropFrame = false,
  bool treatIncompleteAsIssue = true,
}) =>
    validateTimecode(
      segments: segments,
      fpsMode: fpsMode,
      isDropFrame: isDropFrame,
      treatIncompleteAsIssue: treatIncompleteAsIssue,
    );

void main() {
  group('validateTimecode', () {
    // ── HH 범위 검증 ──────────────────────────────────────────
    group('HH 범위 (0–23)', () {
      test('HH=00 은 유효', () {
        final result = _validate(_seg('00', '00', '00', '00'));
        expect(result.isValid, isTrue);
      });

      test('HH=23 은 유효', () {
        final result = _validate(_seg('23', '59', '59', '29'));
        expect(result.isValid, isTrue);
      });

      test('HH=24 는 에러', () {
        final result = _validate(_seg('24', '00', '00', '00'));
        expect(result.isValid, isFalse);
        expect(result.issue?.message, contains('Hours must be 00–23'));
        expect(result.issue?.severity, TimecodeIssueSeverity.error);
      });

      test('HH=99 는 에러', () {
        final result = _validate(_seg('99', '00', '00', '00'));
        expect(result.isValid, isFalse);
        expect(result.issue?.message, contains('Hours must be 00–23'));
      });
    });

    // ── MM/SS 범위 검증 ───────────────────────────────────────
    group('MM/SS 범위', () {
      test('MM=60 은 에러', () {
        final result = _validate(_seg('00', '60', '00', '00'));
        expect(result.isValid, isFalse);
        expect(result.issue?.message, contains('Minutes must be 00–59'));
      });

      test('SS=60 은 에러', () {
        final result = _validate(_seg('00', '00', '60', '00'));
        expect(result.isValid, isFalse);
        expect(result.issue?.message, contains('Seconds must be 00–59'));
      });

      test('FF=frameBase(30) 는 에러 (29.97 기준)', () {
        final result = _validate(
          _seg('00', '00', '00', '30'),
          fpsMode: FpsMode.fps29_97,
        );
        expect(result.isValid, isFalse);
        expect(result.issue?.message, contains('Frames must be'));
      });

      test('FF=24 는 에러 (24fps 기준)', () {
        final result = _validate(
          _seg('00', '00', '00', '24'),
          fpsMode: FpsMode.fps24,
        );
        expect(result.isValid, isFalse);
      });
    });

    // ── isComplete 동작 확인 ──────────────────────────────────
    // 참고: TimecodeSegments.isComplete은 padLeft(2,'0')를 사용하므로
    // 빈 문자열('')도 '00'으로 패딩되어 항상 complete로 처리됨.
    // 따라서 빈 세그먼트는 00:00:00:00 TC로 파싱되어 유효함.
    group('빈 세그먼트 처리', () {
      test('빈 세그먼트는 00:00:00:00 으로 파싱되어 유효', () {
        final result = _validate(
          _seg('', '', '', ''),
          treatIncompleteAsIssue: true,
        );
        expect(result.isValid, isTrue);
        expect(result.timecode?.hours, 0);
        expect(result.timecode?.minutes, 0);
        expect(result.timecode?.seconds, 0);
        expect(result.timecode?.frames, 0);
      });

      test('단일 자리 세그먼트도 패딩 후 유효', () {
        final result = _validate(
          _seg('1', '2', '3', '4'),
          fpsMode: FpsMode.fps29_97,
        );
        expect(result.isValid, isTrue);
        expect(result.timecode?.hours, 1);
        expect(result.timecode?.minutes, 2);
        expect(result.timecode?.seconds, 3);
        expect(result.timecode?.frames, 4);
      });
    });

    // ── Drop-Frame illegal label ──────────────────────────────
    group('DF illegal label (29.97)', () {
      test('00:01:00;00 — minute start, 10분 단위 아님 → 에러', () {
        final result = _validate(
          _seg('00', '01', '00', '00'),
          fpsMode: FpsMode.fps29_97,
          isDropFrame: true,
        );
        expect(result.isValid, isFalse);
        expect(result.issue?.message, contains('Illegal DF label'));
      });

      test('00:01:00;01 — frame=1, 10분 단위 아님 → 에러', () {
        final result = _validate(
          _seg('00', '01', '00', '01'),
          fpsMode: FpsMode.fps29_97,
          isDropFrame: true,
        );
        expect(result.isValid, isFalse);
      });

      test('00:10:00;00 — 10분 단위 → 유효', () {
        final result = _validate(
          _seg('00', '10', '00', '00'),
          fpsMode: FpsMode.fps29_97,
          isDropFrame: true,
        );
        expect(result.isValid, isTrue);
      });

      test('00:20:00;01 — 20분 단위 → 유효', () {
        final result = _validate(
          _seg('00', '20', '00', '01'),
          fpsMode: FpsMode.fps29_97,
          isDropFrame: true,
        );
        expect(result.isValid, isTrue);
      });

      test('00:01:00;02 — frame=2, 아무 분이나 → 유효', () {
        final result = _validate(
          _seg('00', '01', '00', '02'),
          fpsMode: FpsMode.fps29_97,
          isDropFrame: true,
        );
        expect(result.isValid, isTrue);
      });

      test('00:01:01;00 — seconds=1 이면 minute start 아님 → 유효', () {
        final result = _validate(
          _seg('00', '01', '01', '00'),
          fpsMode: FpsMode.fps29_97,
          isDropFrame: true,
        );
        expect(result.isValid, isTrue);
      });
    });

    // ── 정상 유효 케이스 ──────────────────────────────────────
    group('정상 유효 케이스', () {
      test('00:00:00:00 (NDF 29.97) 는 유효', () {
        final result = _validate(_seg('00', '00', '00', '00'));
        expect(result.isValid, isTrue);
        expect(result.timecode?.hours, 0);
        expect(result.timecode?.frames, 0);
      });

      test('23:59:59:29 (29.97 NDF 최대값) 는 유효', () {
        final result = _validate(
          _seg('23', '59', '59', '29'),
          fpsMode: FpsMode.fps29_97,
        );
        expect(result.isValid, isTrue);
      });

      test('00:00:00:23 (24fps 최대 frame) 은 유효', () {
        final result = _validate(
          _seg('00', '00', '00', '23'),
          fpsMode: FpsMode.fps24,
        );
        expect(result.isValid, isTrue);
      });
    });
  });
}
