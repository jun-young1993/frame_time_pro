import 'package:flutter/material.dart';

/// Adaptive size tokens: phone defaults vs. tablet overrides.
///
/// All values follow the 8pt grid. Pass [isTablet] (obtained via
/// [AppBreakpoints.isTablet]) to get the appropriate value for the
/// current screen size.
abstract final class AppScale {
  // ── Section inner padding (EdgeInsets.all) ──────────────────────────
  static const double _phoneSectionPad = 16;
  static const double _tabletSectionPad = 32;

  // ── Gap between section title and its content ────────────────────────
  static const double _phoneGap = 12;
  static const double _tabletGap = 24;

  // ── Wrap spacing/runSpacing for chip groups ──────────────────────────
  static const double _phoneChipSpacing = 8;
  static const double _tabletChipSpacing = 16;

  // ── Display box vertical padding ────────────────────────────────────
  static const double _phoneDisplayPadV = 16;
  static const double _tabletDisplayPadV = 32;

  // ── AppBar status-strip height ───────────────────────────────────────
  static const double _phoneStripH = 36;
  static const double _tabletStripH = 56;

  // ── Public accessors ─────────────────────────────────────────────────

  /// Inner padding for [AppSectionContainer] children.
  static double sectionPadding(bool isTablet) =>
      isTablet ? _tabletSectionPad : _phoneSectionPad;

  /// Vertical gap between a section title and its content area.
  static double gap(bool isTablet) => isTablet ? _tabletGap : _phoneGap;

  /// Spacing and runSpacing for [Wrap] chip groups.
  static double chipSpacing(bool isTablet) =>
      isTablet ? _tabletChipSpacing : _phoneChipSpacing;

  /// Vertical padding inside display/result value containers.
  static double displayPaddingV(bool isTablet) =>
      isTablet ? _tabletDisplayPadV : _phoneDisplayPadV;

  /// Preferred height of the AppBar status strip.
  static double statusStripHeight(bool isTablet) =>
      isTablet ? _tabletStripH : _phoneStripH;

  /// Section title text style — one step up on tablet.
  static TextStyle? sectionTitle(TextTheme t, bool isTablet) =>
      isTablet ? t.titleLarge : t.titleMedium;
}
