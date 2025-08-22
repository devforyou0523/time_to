import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget svgWithShadow({
  required String assetName,
  double width = 300,
  double height = 300,
}) {
  return RepaintBoundary(
    child: Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: Offset(4, 4),
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
              tileMode: ui.TileMode.decal,
            ),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withAlpha(100),
                BlendMode.srcATop,
              ),
              child: SvgPicture.asset(
                assetName,
                width: width,
                height: height,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.9,
          child: SvgPicture.asset(
            assetName,
            width: width,
            height: height,
            fit: BoxFit.contain,
          ),
        ),
      ],
    ),
  );
}
