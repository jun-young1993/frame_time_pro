import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_section_container.dart';
import '../../application/timecode_calculator_notifier.dart';
import '../../domain/fps_mode.dart';

class FrameRateSelectorSection extends ConsumerWidget {
  const FrameRateSelectorSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final fpsMode = ref.watch(timecodeCalculatorProvider.select((s) => s.fpsMode));
    final isDropFrame = ref.watch(timecodeCalculatorProvider.select((s) => s.isDropFrame));
    final allowsDf = fpsMode.allowsDropFrame;

    return AppSectionContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Frame rate', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Semantics(
              label: 'Frame rate selector',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final mode in FpsMode.values)
                    ChoiceChip(
                      label: Text(mode.label),
                      selected: mode.label == fpsMode.label,
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        ref.read(timecodeCalculatorProvider.notifier).setFpsMode(mode);
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Drop frame toggle',
                    enabled: allowsDf,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Drop-frame (DF)'),
                      subtitle: Text(
                        allowsDf ? 'Available for 29.97' : 'Drop-frame is only available at 29.97.',
                        style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      value: allowsDf ? isDropFrame : false,
                      onChanged: allowsDf
                          ? (value) {
                              HapticFeedback.selectionClick();
                              ref.read(timecodeCalculatorProvider.notifier).setDropFrame(value);
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            if (isDropFrame) ...[
              const SizedBox(height: 8),
              Text(
                'DF skips frame numbers to match clock time (frames are not removed).',
                style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

