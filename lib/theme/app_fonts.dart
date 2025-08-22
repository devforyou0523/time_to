import 'package:flutter/material.dart';

class AppFonts {
  /// 화면 크기 비례 폰트 (shortestSide 기준)
  static double responsive(
    BuildContext context,
    double ratio, {
    double min = 12,
    double max = 24,
  }) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    final fontSize = shortestSide * ratio;

    return fontSize.clamp(min, max);
  }

  // 자주 쓰는 폰트 사이즈 프리셋
  static double title(BuildContext context) =>
      responsive(context, 0.06, min: 18, max: 28);

  static double body(BuildContext context) =>
      responsive(context, 0.05, min: 16, max: 22);

  static double caption(BuildContext context) =>
      responsive(context, 0.035, min: 12, max: 16);
}
