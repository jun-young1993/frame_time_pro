import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_ui_kit_theme/flutter_ui_kit_theme.dart';

import '../../../../core/widgets/app_section_container.dart';
import '../../application/timecode_calculator_notifier.dart';
import '../../application/timecode_calculator_state.dart';

class ConversionModeSection extends ConsumerWidget {
  const ConversionModeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isTablet = AppBreakpoints.isTablet(MediaQuery.sizeOf(context).width);
    final selected = ref.watch(
      timecodeCalculatorProvider.select((s) => s.conversionMode),
    );


    final pad = AppScale.sectionPadding(isTablet);
    final spacing = AppScale.chipSpacing(isTablet);

    return AppSectionContainer(
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Conversion', style: AppScale.sectionTitle(textTheme, isTablet)),
            SizedBox(height: AppScale.gap(isTablet)),
            Semantics(
              label: 'Conversion mode',
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: ConversionMode.values.map((mode) {
                  final isSelected = mode == selected;
                  return FilterChip(
                    label: Text(mode.label, style: textTheme.labelLarge?.copyWith(color: scheme.primary)),
                    selected: isSelected,
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      ref.read(timecodeCalculatorProvider.notifier).setConversionMode(mode);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
