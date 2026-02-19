import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../application/timecode_calculator_state.dart';
import '../../domain/fps_mode.dart';
import '../../domain/timecode.dart';
import '../../domain/timecode_math.dart';

class TimecodeKeypadBottomSheet extends StatefulWidget {
  const TimecodeKeypadBottomSheet({
    super.key,
    required this.title,
    required this.initialSegments,
    required this.fpsMode,
    required this.isDropFrame,
    required this.onChanged,
    required this.onNudge,
  });

  final String title;
  final TimecodeSegments initialSegments;
  final FpsMode fpsMode;
  final bool isDropFrame;
  final ValueChanged<TimecodeSegments> onChanged;
  final ValueChanged<TimecodeSegments> onNudge;

  @override
  State<TimecodeKeypadBottomSheet> createState() => _TimecodeKeypadBottomSheetState();
}

class _TimecodeKeypadBottomSheetState extends State<TimecodeKeypadBottomSheet> {
  late TimecodeSegments _segments;
  TimecodeSegment _focused = TimecodeSegment.hh;
  Timer? _repeatTimer;
  int _repeatCount = 0;

  @override
  void initState() {
    super.initState();
    _segments = widget.initialSegments;
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.title, style: textTheme.titleLarge)),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SegmentsRow(
              segments: _segments,
              isDropFrame: widget.isDropFrame,
              focused: _focused,
              onFocus: (seg) {
                setState(() => _focused = seg);
                HapticFeedback.selectionClick();
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StepperButton(
                    label: '-1F',
                    onTap: () => _stepByFrames(-1, shouldAnimate: true),
                    onRepeatStart: () => _startRepeat(
                      initial: () => _stepByFrames(-1, shouldAnimate: true),
                      repeat: () => _stepByFrames(-1, shouldAnimate: false),
                    ),
                    onRepeatEnd: _stopRepeat,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StepperButton(
                    label: '+1F',
                    onTap: () => _stepByFrames(1, shouldAnimate: true),
                    onRepeatStart: () => _startRepeat(
                      initial: () => _stepByFrames(1, shouldAnimate: true),
                      repeat: () => _stepByFrames(1, shouldAnimate: false),
                    ),
                    onRepeatEnd: _stopRepeat,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _stepByFrames(10, shouldAnimate: true),
                    child: const Text('+10F'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _stepByFrames(widget.fpsMode.frameBase, shouldAnimate: true),
                    child: const Text('+1S'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _NumericPad(
              onDigit: _appendDigit,
              onBackspace: _backspace,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                    child: Text('Cancel', style: textTheme.labelLarge?.copyWith(color: scheme.onSurface)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(_segments);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _notifyChanged() => widget.onChanged(_segments);

  void _appendDigit(int digit) {
    final d = digit.toString();
    final before = _segments;

    final (updated, didComplete) = switch (_focused) {
      TimecodeSegment.hh => _updateSegment(before.hh, d, (v) => before.copyWith(hh: v)),
      TimecodeSegment.mm => _updateSegment(before.mm, d, (v) => before.copyWith(mm: v)),
      TimecodeSegment.ss => _updateSegment(before.ss, d, (v) => before.copyWith(ss: v)),
      TimecodeSegment.ff => _updateSegment(before.ff, d, (v) => before.copyWith(ff: v)),
    };

    setState(() {
      _segments = updated;
      if (didComplete) _focused = _next(_focused);
    });
    _notifyChanged();
  }

  (TimecodeSegments, bool) _updateSegment(
    String current,
    String digit,
    TimecodeSegments Function(String next) apply,
  ) {
    if (current.isEmpty) return (apply(digit), false);
    if (current.length == 1) return (apply('$current$digit'), true);

    // Shift-left overwrite for continuous entry.
    final shifted = '${current[1]}$digit';
    return (apply(shifted), false);
  }

  void _backspace() {
    final before = _segments;

    String get(TimecodeSegment seg) => switch (seg) {
          TimecodeSegment.hh => before.hh,
          TimecodeSegment.mm => before.mm,
          TimecodeSegment.ss => before.ss,
          TimecodeSegment.ff => before.ff,
        };
    TimecodeSegments set(TimecodeSegment seg, String value) => switch (seg) {
          TimecodeSegment.hh => before.copyWith(hh: value),
          TimecodeSegment.mm => before.copyWith(mm: value),
          TimecodeSegment.ss => before.copyWith(ss: value),
          TimecodeSegment.ff => before.copyWith(ff: value),
        };

    var seg = _focused;
    var value = get(seg);
    if (value.isEmpty) {
      seg = _prev(seg);
      value = get(seg);
    }

    final nextValue = value.isEmpty ? value : value.substring(0, value.length - 1);
    setState(() {
      _focused = seg;
      _segments = set(seg, nextValue);
    });
    _notifyChanged();
  }

  void _stepByFrames(int deltaFrames, {required bool shouldAnimate}) {
    final padded = _segments.copyWith(
      hh: _segments.hh.padLeft(2, '0'),
      mm: _segments.mm.padLeft(2, '0'),
      ss: _segments.ss.padLeft(2, '0'),
      ff: _segments.ff.padLeft(2, '0'),
    );

    final validation = validateTimecode(
      segments: padded,
      fpsMode: widget.fpsMode,
      isDropFrame: widget.isDropFrame,
      treatIncompleteAsIssue: true,
    );
    if (!validation.isValid) {
      HapticFeedback.heavyImpact();
      return;
    }

    final baseFrames = TimecodeMath.toFrameNumber(
      timecode: validation.timecode!,
      fpsMode: widget.fpsMode,
      isDropFrame: widget.isDropFrame,
    );

    final nextFrames = (baseFrames + deltaFrames).clamp(0, 0x7FFFFFFF);
    final nextTc = TimecodeMath.fromFrameNumber(
      frameNumber: nextFrames,
      fpsMode: widget.fpsMode,
      isDropFrame: widget.isDropFrame,
    );

    final nextSegments = TimecodeSegments(
      hh: nextTc.hours.toString().padLeft(2, '0').substring(0, 2),
      mm: nextTc.minutes.toString().padLeft(2, '0'),
      ss: nextTc.seconds.toString().padLeft(2, '0'),
      ff: nextTc.frames.toString().padLeft(2, '0'),
    );

    setState(() => _segments = nextSegments);
    if (shouldAnimate) {
      widget.onNudge(_segments);
    } else {
      widget.onChanged(_segments);
    }
    HapticFeedback.selectionClick();
  }

  void _startRepeat({required VoidCallback initial, required VoidCallback repeat}) {
    _stopRepeat();
    _repeatCount = 0;
    initial();
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 110), (_) {
      _repeatCount += 1;
      if (_repeatCount == 1) return;
      if (_repeatCount % 6 == 0) HapticFeedback.selectionClick();
      repeat();
    });
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
    _repeatCount = 0;
  }

  static TimecodeSegment _next(TimecodeSegment seg) => switch (seg) {
        TimecodeSegment.hh => TimecodeSegment.mm,
        TimecodeSegment.mm => TimecodeSegment.ss,
        TimecodeSegment.ss => TimecodeSegment.ff,
        TimecodeSegment.ff => TimecodeSegment.hh,
      };

  static TimecodeSegment _prev(TimecodeSegment seg) => switch (seg) {
        TimecodeSegment.hh => TimecodeSegment.ff,
        TimecodeSegment.mm => TimecodeSegment.hh,
        TimecodeSegment.ss => TimecodeSegment.mm,
        TimecodeSegment.ff => TimecodeSegment.ss,
      };
}

class _SegmentsRow extends StatelessWidget {
  const _SegmentsRow({
    required this.segments,
    required this.isDropFrame,
    required this.focused,
    required this.onFocus,
  });

  final TimecodeSegments segments;
  final bool isDropFrame;
  final TimecodeSegment focused;
  final ValueChanged<TimecodeSegment> onFocus;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sep = isDropFrame ? ';' : ':';
    final style = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
          letterSpacing: 0.5,
        );

    Widget segButton(TimecodeSegment seg, String value) {
      final isFocused = seg == focused;
      return Expanded(
        child: Semantics(
          button: true,
          selected: isFocused,
          label: 'Segment ${seg.name.toUpperCase()}',
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onFocus(seg),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isFocused ? scheme.primaryContainer : scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isFocused ? scheme.primary : scheme.outlineVariant),
              ),
              child: Text(value.padLeft(2, '0'), style: style),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        segButton(TimecodeSegment.hh, segments.hh),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(':', style: style?.copyWith(color: scheme.onSurfaceVariant)),
        ),
        segButton(TimecodeSegment.mm, segments.mm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(':', style: style?.copyWith(color: scheme.onSurfaceVariant)),
        ),
        segButton(TimecodeSegment.ss, segments.ss),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(sep, style: style?.copyWith(color: scheme.onSurfaceVariant)),
        ),
        segButton(TimecodeSegment.ff, segments.ff),
      ],
    );
  }
}

class _NumericPad extends StatelessWidget {
  const _NumericPad({
    required this.onDigit,
    required this.onBackspace,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget digit(int n) {
      return FilledButton.tonal(
        onPressed: () {
          HapticFeedback.selectionClick();
          onDigit(n);
        },
        child: Text(n.toString()),
      );
    }

    return Column(
      children: [
        Row(children: [Expanded(child: digit(1)), const SizedBox(width: 12), Expanded(child: digit(2)), const SizedBox(width: 12), Expanded(child: digit(3))]),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: digit(4)), const SizedBox(width: 12), Expanded(child: digit(5)), const SizedBox(width: 12), Expanded(child: digit(6))]),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: digit(7)), const SizedBox(width: 12), Expanded(child: digit(8)), const SizedBox(width: 12), Expanded(child: digit(9))]),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onBackspace();
                },
                child: const Icon(Icons.backspace_outlined),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: digit(0)),
            const SizedBox(width: 12),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.label,
    required this.onTap,
    required this.onRepeatStart,
    required this.onRepeatEnd,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback onRepeatStart;
  final VoidCallback onRepeatEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => onRepeatStart(),
      onLongPressEnd: (_) => onRepeatEnd(),
      child: FilledButton.tonal(
        onPressed: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Text(label),
      ),
    );
  }
}

