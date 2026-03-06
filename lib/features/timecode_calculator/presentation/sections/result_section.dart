import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_ui_kit_theme/flutter_ui_kit_theme.dart';
import '../../../../core/widgets/app_section_container.dart';
import '../../application/timecode_calculator_notifier.dart';
import '../../../history/application/history_notifier.dart';
import '../../../history/domain/conversion_record.dart';

class ResultSection extends ConsumerWidget {
  const ResultSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isTablet = AppBreakpoints.isTablet(MediaQuery.sizeOf(context).width);

    final result = ref.watch(timecodeCalculatorProvider.select((s) => s.result));
    final nonce = ref.watch(timecodeCalculatorProvider.select((s) => s.resultAnimationNonce));

    final resultColor = result.isNegative ? scheme.onSurfaceVariant : scheme.onSurface;
    final pad = AppScale.sectionPadding(isTablet);
    final displayPadV = AppScale.displayPaddingV(isTablet);

    return AppSectionContainer(
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text('Result', style: AppScale.sectionTitle(textTheme, isTablet))),
                IconButton(
                  tooltip: 'Copy result',
                  onPressed: result.isValid
                      ? () async {
                          await Clipboard.setData(ClipboardData(text: result.display));
                          HapticFeedback.lightImpact();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
                        }
                      : null,
                  icon: const Icon(Icons.copy_outlined),
                ),
                IconButton(
                  tooltip: 'Save to history',
                  onPressed: result.isValid
                      ? () async {
                          final state = ref.read(timecodeCalculatorProvider);
                          await ref.read(historyProvider.notifier).save(
                                ConversionRecord(
                                  conversionType: state.statusModeLabel,
                                  inputValue: state.inputDisplay,
                                  outputValue: state.result.display,
                                  timestamp: DateTime.now(),
                                ),
                              );
                          HapticFeedback.lightImpact();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saved to history')),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.bookmark_add_outlined),
                ),
              ],
            ),
            SizedBox(height: AppScale.gap(isTablet)),
            Semantics(
              label: 'Calculated result',
              value: result.display,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: displayPadV, horizontal: pad),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      result.display,
                      textAlign: TextAlign.center,
                      style: textTheme.displaySmall?.copyWith(
                        color: resultColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: 1.0,
                      ),
                    ),
                  )
                      .animate(key: ValueKey(nonce))
                      .fadeIn(duration: 250.ms)
                      .slideY(begin: 0.06, end: 0, duration: 250.ms, curve: Curves.easeOutCubic),
                ),
              ),
            ),
            if (!result.isValid) ...[
              const SizedBox(height: 8),
              Text(
                'Enter a value and see the conversion result.',
                style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

