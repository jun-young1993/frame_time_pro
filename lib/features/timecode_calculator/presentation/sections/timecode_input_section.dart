import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_section_container.dart';
import '../../application/timecode_calculator_notifier.dart';
import '../../application/timecode_calculator_state.dart';
import '../../domain/fps_mode.dart';
import '../../domain/timecode.dart';
import '../components/timecode_keypad_bottom_sheet.dart';

class TimecodeInputSection extends ConsumerWidget {
  const TimecodeInputSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final mode = ref.watch(timecodeCalculatorProvider.select((s) => s.conversionMode));
    final fpsMode = ref.watch(timecodeCalculatorProvider.select((s) => s.fpsMode));
    final isDropFrame = ref.watch(timecodeCalculatorProvider.select((s) => s.isDropFrame));
    final inputA = ref.watch(timecodeCalculatorProvider.select((s) => s.inputA));
    final frameInput = ref.watch(timecodeCalculatorProvider.select((s) => s.frameInput));
    final secondInput = ref.watch(timecodeCalculatorProvider.select((s) => s.secondInput));
    final notifier = ref.read(timecodeCalculatorProvider.notifier);

    String title;
    Widget inputWidget;

    if (mode.inputIsTimecode) {
      title = 'Input (Timecode)';
      inputWidget = _TimecodeField(
        label: 'Timecode',
        value: inputA.segments.display(isDropFrame: isDropFrame),
        helper: inputA.issue?.message,
        helperSeverity: inputA.issue?.severity,
        isActive: true,
        onTap: () async {
          await _openKeypad(
            context: context,
            title: 'Timecode',
            ref: ref,
            initial: inputA.segments,
            fpsMode: fpsMode,
            isDropFrame: isDropFrame,
          );
        },
      );
    } else if (mode.inputIsFrame) {
      title = 'Input (Frames)';
      inputWidget = _NumberField(
        label: 'Frames',
        value: frameInput,
        hint: '0',
        keyboardType: TextInputType.number,
        onChanged: notifier.setFrameInput,
      );
    } else {
      title = 'Input (Seconds)';
      inputWidget = _NumberField(
        label: 'Seconds',
        value: secondInput,
        hint: '0',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: notifier.setSecondInput,
      );
    }

    return AppSectionContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 12),
            inputWidget,
            const SizedBox(height: 8),
            Text(
              '${fpsMode.label}${isDropFrame ? ' DF' : ''}',
              style: textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _openKeypad({
    required BuildContext context,
    required String title,
    required WidgetRef ref,
    required TimecodeSegments initial,
    required FpsMode fpsMode,
    required bool isDropFrame,
  }) async {
    final notifier = ref.read(timecodeCalculatorProvider.notifier);
    final original = initial;

    final committed = await showModalBottomSheet<TimecodeSegments?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return TimecodeKeypadBottomSheet(
          title: title,
          initialSegments: initial,
          fpsMode: fpsMode,
          isDropFrame: isDropFrame,
          onChanged: (segments) {
            notifier.setInputSegments(segments, isCommit: false, shouldAnimateResult: false);
          },
          onNudge: (segments) {
            notifier.setInputSegments(segments, isCommit: false, shouldAnimateResult: true);
          },
        );
      },
    );

    if (committed == null) {
      notifier.setInputSegments(original, isCommit: false, shouldAnimateResult: false);
      return;
    }

    final validation = validateTimecode(
      segments: committed,
      fpsMode: fpsMode,
      isDropFrame: isDropFrame,
      treatIncompleteAsIssue: true,
    );
    if (!validation.isValid) HapticFeedback.heavyImpact();

    notifier.setInputSegments(committed, isCommit: true, shouldAnimateResult: true);
  }
}

class _TimecodeField extends StatelessWidget {
  const _TimecodeField({
    required this.label,
    required this.value,
    required this.helper,
    required this.helperSeverity,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String value;
  final String? helper;
  final TimecodeIssueSeverity? helperSeverity;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasHelper = helper != null && helper!.isNotEmpty;

    final helperColor = switch (helperSeverity) {
      TimecodeIssueSeverity.warning => scheme.tertiary,
      TimecodeIssueSeverity.error => scheme.error,
      null => scheme.onSurfaceVariant,
    };

    return Semantics(
      button: true,
      label: '$label input',
      value: value,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasHelper
                  ? (helperSeverity == TimecodeIssueSeverity.warning ? scheme.tertiary : scheme.error)
                  : (isActive ? scheme.primary : scheme.outlineVariant),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(label, style: textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
                  ),
                  Icon(Icons.keyboard, color: scheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value.isEmpty ? '00:00:00:00' : value,
                  style: textTheme.titleLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (hasHelper) ...[
                const SizedBox(height: 8),
                Text(helper!, style: textTheme.bodySmall?.copyWith(color: helperColor)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.hint,
    required this.keyboardType,
    required this.onChanged,
  });

  final String label;
  final String value;
  final String hint;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '${widget.label} input',
      value: widget.value,
      child: TextField(
        controller: _controller,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: scheme.surfaceContainerHighest,
        ),
        style: textTheme.titleLarge?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
