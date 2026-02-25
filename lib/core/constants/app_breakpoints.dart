abstract final class AppBreakpoints {
  /// Two-column layout breakpoint.
  static const double wide = 600;

  /// Tablet / large-screen breakpoint for scaled-up UI elements.
  static const double tablet = 768;

  /// Returns true when [width] is at or above the tablet breakpoint.
  static bool isTablet(double width) => width >= tablet;
}

