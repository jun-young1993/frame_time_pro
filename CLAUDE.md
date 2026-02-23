# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Frame Time Pro is a Flutter app for SMPTE timecode and drop-frame calculations targeting broadcast professionals. It supports 6 conversion modes between frames, timecodes, and seconds across 5 FPS rates.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter run -d <device>  # Run on specific device
flutter test             # Run all tests
flutter test test/path/to/test.dart  # Run single test file
flutter analyze          # Static analysis (flutter_lints)
flutter build apk        # Android build
flutter build ios        # iOS build
```

## Architecture

Feature-based clean architecture under `lib/features/timecode_calculator/`:

- **`domain/`** — Pure Dart, no Flutter dependencies
  - `fps_mode.dart`: 5 FPS modes (23.976, 24, 25, 29.97, 30); drop-frame only allowed at 29.97
  - `timecode.dart`: `Timecode` / `TimecodeSegments` models; `validateTimecode()` with SMPTE DF validation rules
  - `timecode_math.dart`: Core SMPTE algorithms — `toFrameNumber()` / `fromFrameNumber()` with drop-frame support

- **`application/`** — Riverpod state management
  - `timecode_calculator_state.dart`: `ConversionMode` enum (6 modes), `TimecodeCalculatorState`
  - `timecode_calculator_notifier.dart`: `timecodeCalculatorProvider` (StateNotifier); `_recompute()` drives all conversion logic on any input change

- **`presentation/`** — Flutter UI
  - `timecode_calculator_screen.dart`: Responsive layout — vertical (portrait) vs. two-column (wide, ≥600dp via `AppBreakpoints.wide`)
  - `sections/`: One file per screen section (conversion mode, frame rate, input, result, etc.)
  - `components/timecode_keypad_bottom_sheet.dart`: Modal keypad with segment focus management, step buttons (±1 frame, ±10 frames, +1 second), long-press repeat

Shared utilities in `lib/core/`:
- `constants/app_spacing.dart`: 8pt spacing tokens
- `constants/app_breakpoints.dart`: `wide = 600` breakpoint
- `theme/app_theme.dart`: Dark Material 3 theme (seed: Indigo #6366F1, bg: #0F1115)
- `widgets/app_section_container.dart`: Styled card container used throughout

## Key Conventions

- **State**: All state mutations go through `timecodeCalculatorProvider` methods; `_recompute()` is the single place where conversions are recalculated.
- **Drop-frame validation**: SMPTE DF rules prohibit certain timecode labels (minute-start frames 0 and 1 except on every 10th minute). See `validateTimecode()` in `timecode.dart`.
- **Typography**: JetBrains Mono for timecode/numeric display; Noto Sans KR for UI text.
- **Responsive**: Check `MediaQuery.of(context).size.width >= AppBreakpoints.wide` for layout branching.
- **ScreenUtil**: `flutter_screenutil` is initialized in `main.dart`; use `.sp`, `.w`, `.h` extensions for scaled sizes.
