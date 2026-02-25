import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_breakpoints.dart';
import '../../../../core/constants/app_scale.dart';
import '../../../../core/widgets/app_section_container.dart';
import '../../application/timecode_calculator_notifier.dart';
import '../../domain/fps_mode.dart';

class FrameRateSelectorSection extends ConsumerWidget {
  const FrameRateSelectorSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isTablet = AppBreakpoints.isTablet(MediaQuery.sizeOf(context).width);

    final fpsMode = ref.watch(timecodeCalculatorProvider.select((s) => s.fpsMode));
    final isDropFrame = ref.watch(timecodeCalculatorProvider.select((s) => s.isDropFrame));
    final allowsDf = fpsMode.allowsDropFrame;

    final pad = AppScale.sectionPadding(isTablet);
    final spacing = AppScale.chipSpacing(isTablet);

    return AppSectionContainer(
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Frame rate', style: AppScale.sectionTitle(textTheme, isTablet)),
            SizedBox(height: AppScale.gap(isTablet)),
            Semantics(
              label: 'Frame rate selector',
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
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
            SizedBox(height: AppScale.gap(isTablet)),
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

