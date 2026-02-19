import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_section_container.dart';
import '../../application/timecode_calculator_notifier.dart';
import '../../application/timecode_calculator_state.dart';

class TimecodeDisplaySection extends ConsumerWidget {
  const TimecodeDisplaySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final mode = ref.watch(timecodeCalculatorProvider.select((s) => s.conversionMode));
    final isDropFrame = ref.watch(timecodeCalculatorProvider.select((s) => s.isDropFrame));
    final inputA = ref.watch(timecodeCalculatorProvider.select((s) => s.inputA));
    final frameInput = ref.watch(timecodeCalculatorProvider.select((s) => s.frameInput));
    final secondInput = ref.watch(timecodeCalculatorProvider.select((s) => s.secondInput));

    String label;
    String value;
    if (mode.inputIsTimecode) {
      label = 'Input (Timecode)';
      value = inputA.segments.display(isDropFrame: isDropFrame);
      if (value.isEmpty) value = '00:00:00:00';
    } else if (mode.inputIsFrame) {
      label = 'Input (Frames)';
      value = frameInput.isEmpty ? '0' : frameInput;
    } else {
      label = 'Input (Seconds)';
      value = secondInput.isEmpty ? '0' : secondInput;
    }

    return AppSectionContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(label, style: textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.12),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: 1.0,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
