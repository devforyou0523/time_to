import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_colors.dart';
import '../../widgets/svg_with_shadow.dart';
import '../../theme/app_fonts.dart';
import 'sleep_timer_main.dart';

enum ResultType { sleep, wake }

class ResultView extends StatelessWidget {
  final TimeSelection sleepTime;
  final TimeSelection wakeTime;
  final VoidCallback onBack;
  final ResultType type;

  const ResultView({
    super.key,
    required this.sleepTime,
    required this.wakeTime,
    required this.onBack,
    required this.type,
  });

  void _showHelp(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'info_dialog',
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(180),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (buildContext, a1, a2) {
        return SafeArea(
          child: Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              onTap: () => Navigator.of(buildContext).pop(),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                  child: Container(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {}, // 다이얼로그 내부 탭 방지
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 28),
                        padding: EdgeInsets.all(AppFonts.title(context) * 1.4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '수면 타이머의 작동 방식은?',
                              style: TextStyle(
                                fontSize: AppFonts.body(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: AppFonts.title(context)),
                            Text(
                              '- 수면은 5~6회의 사이클로 구성되며, 각 사이클은 약 90분 동안 지속됩니다.\n\n'
                              '- 수면 주기 도중에 일어나면 피곤함을 유발하지만, 주기 사이에 일어난다면 상쾌함을 줄 수 있습니다.\n\n'
                              '- 이 타이머는 수면 주기를 계산하여 당신의 상쾌한 수면을 돕습니다!',
                              style: TextStyle(
                                fontSize: AppFonts.body(context) * 0.85,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(height: AppFonts.title(context) * 4),
                            Text(
                              '빈 곳을 눌러 도움말 종료하기',
                              style: TextStyle(
                                fontSize: AppFonts.body(context) * 0.7,
                                fontWeight: FontWeight.w300,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 상단 바 (뒤로가기 + 타이틀 + info)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onBack,
                    icon: SvgPicture.asset(
                      'assets/images/icons/arrow_3.svg',
                      width: AppFonts.title(context),
                      height: AppFonts.title(context),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '수면 타이머',
                      style: TextStyle(
                        fontSize: AppFonts.title(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showHelp(context),
                      icon: SvgPicture.asset(
                        'assets/images/icons/info.svg',
                        width: AppFonts.title(context),
                        height: AppFonts.title(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 메인 일러스트 (달)
          svgWithShadow(
            assetName: "assets/images/moon.svg",
            height: AppFonts.title(context) * 12,
            width: AppFonts.title(context) * 12,
          ),

          // ✅ type에 따라 sleepTime 또는 wakeTime 출력
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                type == ResultType.sleep ? "취침 시간" : "기상 시간",
                style: TextStyle(
                  fontSize: AppFonts.body(context),
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: type == ResultType.sleep
                          ? sleepTime
                                .period // 오전/오후
                          : wakeTime.period,
                      style: TextStyle(
                        fontSize: AppFonts.title(context) * 1.1,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const TextSpan(text: "  "), // 띄어쓰기
                    TextSpan(
                      text: type == ResultType.sleep
                          ? "${sleepTime.hour}"
                          : "${wakeTime.hour}",
                      style: TextStyle(
                        fontSize: AppFonts.title(context) * 1.4, // 큰 글씨
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: "시",
                      style: TextStyle(
                        fontSize: AppFonts.title(context) * 1.4, // 큰 글씨
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    const TextSpan(text: " "), // 띄어쓰기
                    TextSpan(
                      text: type == ResultType.sleep
                          ? sleepTime.minute.toString().padLeft(2, '0')
                          : wakeTime.minute.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: AppFonts.title(context) * 1.4, // 큰 글씨
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: "분",
                      style: TextStyle(
                        fontSize: AppFonts.title(context) * 1.4, // 큰 글씨
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              //TODO: 시간 추천 컨테이너 추가
              Container(
                child: Column(
                  children: [
                    Row(children: []),
                    Container(),
                    Row(children: []),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
