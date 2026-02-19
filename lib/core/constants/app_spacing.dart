import 'package:flutter/widgets.dart';

/// 8pt spacing system tokens.
///
/// Use these values (optionally scaled via ScreenUtil in UI code) to keep
/// layout consistent and broadcast-grade aligned.
abstract final class AppSpacing {
  static const double x0_5 = 4;
  static const double x1 = 8;
  static const double x1_5 = 12;
  static const double x2 = 16;
  static const double x3 = 24;
  static const double x4 = 32;
  static const double x5 = 40;
  static const double x6 = 48;

  static const EdgeInsets screenPadding = EdgeInsets.all(x2);
}

