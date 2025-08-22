import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:time_to/theme/app_colors.dart';

import '../widgets/svg_with_shadow.dart';
import '../theme/app_fonts.dart';

class SleepTimerPage extends StatelessWidget {
  const SleepTimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '수면 타이머',
              style: TextStyle(
                fontSize: AppFonts.title(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/images/icons/info.svg',
                width: AppFonts.title(context),
                height: AppFonts.title(context),
              ),
            ),
          ],
        ),
        svgWithShadow(
          assetName: "assets/images/moon.svg",
          height: AppFonts.title(context) * 12,
          width: AppFonts.title(context) * 12,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '내가 잠에 들 시간은?',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: AppFonts.body(context),
                  ),
                ),
                SvgPicture.asset(
                  "assets/images/icons/arrow_1.svg",
                  width: AppFonts.body(context),
                  height: AppFonts.body(context),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: AppFonts.title(context) * 4,
          padding: EdgeInsets.all(AppFonts.title(context)),
          decoration: BoxDecoration(
            color: AppColors.containerPrimary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("오후", style: TextStyle(fontSize: AppFonts.title(context))),
              Row(
                children: [
                  UnderlinedTextWithSpacing(text: "10"),
                  Text(
                    "시 ",
                    style: TextStyle(
                      fontSize: AppFonts.title(context) * 1.3,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  Text(
                    "30",
                    style: TextStyle(
                      fontSize: AppFonts.title(context) * 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "분",
                    style: TextStyle(
                      fontSize: AppFonts.title(context) * 1.3,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UnderlinedTextWithSpacing extends StatelessWidget {
  final String text;

  const UnderlinedTextWithSpacing({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Stack 밖으로 내용이 나갈 수 있도록 (선택 사항)
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
            fontSize: AppFonts.title(context) * 1.4,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0, // 텍스트 아래로 간격만큼 내리고, 밑줄 두께도 고려
          child: Container(height: 3, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
