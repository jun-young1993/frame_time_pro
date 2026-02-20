import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/constants/app_spacing.dart';
import '../application/timecode_calculator_notifier.dart';
import 'sections/conversion_mode_section.dart';
import 'sections/frame_rate_selector_section.dart';
import 'sections/result_section.dart';
import 'sections/timecode_display_section.dart';
import 'sections/timecode_input_section.dart';

class TimecodeCalculatorScreen extends ConsumerWidget {
  const TimecodeCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusLeft = ref.watch(
      timecodeCalculatorProvider.select((s) => s.statusFpsLabel),
    );
    final statusRight = ref.watch(
      timecodeCalculatorProvider.select((s) => s.statusModeLabel),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timecode Calculator'),
        actions: const [
          // Reserved for future settings / export / history.
          // IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: _StatusStrip(left: statusLeft, right: statusRight),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= AppBreakpoints.wide;
              if (!isWide) return const _PortraitLayout();
              return const _WideLayout();
            },
          ),
        ),
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.left, required this.right});

  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: 'Status',
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                left,
                style: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              right,
              style: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: const [
          ConversionModeSection(),
          SizedBox(height: AppSpacing.x2),
          TimecodeInputSection(),
          SizedBox(height: AppSpacing.x2),
          ResultSection(),
          SizedBox(height: AppSpacing.x2),
          FrameRateSelectorSection(),
          SizedBox(height: AppSpacing.x6),
        ],
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConversionModeSection(),
              SizedBox(height: AppSpacing.x2),
              TimecodeInputSection(),
              SizedBox(height: AppSpacing.x2),
              FrameRateSelectorSection(),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.x2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TimecodeDisplaySection(),
              SizedBox(height: AppSpacing.x2),
              ResultSection(),
            ],
          ),
        ),
      ],
    );
  }
}
