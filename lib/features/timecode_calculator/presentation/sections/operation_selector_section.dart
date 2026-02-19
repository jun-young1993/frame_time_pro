import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_section_container.dart';
import '../../application/timecode_calculator_notifier.dart';
import '../../application/timecode_calculator_state.dart';

class OperationSelectorSection extends ConsumerWidget {
  const OperationSelectorSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final selected = ref.watch(
      timecodeCalculatorProvider.select((s) => s.conversionMode),
    );

    return AppSectionContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Conversion', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Semantics(
              label: 'Conversion mode',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ConversionMode.values.map((mode) {
                  final isSelected = mode == selected;
                  return FilterChip(
                    label: Text(mode.label),
                    selected: isSelected,
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      ref
                          .read(timecodeCalculatorProvider.notifier)
                          .setConversionMode(mode);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select how to convert between frame, timecode, and seconds.',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
