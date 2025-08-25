import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart'; // 날짜 포매팅을 위해 intl 패키지를 추가해주세요.

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

  // 도움말 다이얼로그 표시 함수
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

  // 추천 시간을 계산하는 함수
  List<DateTime> _calculateRecommendedTimes() {
    final List<DateTime> times = [];
    // 기준이 될 시간을 선택 (취침 시간 or 기상 시간)
    final baseTimeSelection = type == ResultType.sleep ? sleepTime : wakeTime;

    // TimeSelection을 DateTime 객체로 변환
    final now = DateTime.now();
    int hour = baseTimeSelection.hour;
    if (baseTimeSelection.period == '오후' && hour != 12) {
      hour += 12;
    } else if (baseTimeSelection.period == '오전' && hour == 12) {
      hour = 0;
    }
    DateTime baseTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      baseTimeSelection.minute,
    );

    // 90분씩 6번 더하거나 빼서 리스트에 추가
    for (int i = 1; i <= 6; i++) {
      if (type == ResultType.sleep) {
        // 기상 시간 추천: 90분씩 더하기
        times.add(baseTime.add(Duration(minutes: 90 * i)));
      } else {
        // 취침 시간 추천: 90분씩 빼기
        times.add(baseTime.subtract(Duration(minutes: 90 * i)));
      }
    }
    return times;
  }

  @override
  Widget build(BuildContext context) {
    final recommendedTimes = _calculateRecommendedTimes();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // main_title_container
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
          // main_container
          svgWithShadow(
            assetName: "assets/images/moon.svg",
            height: AppFonts.title(context) * 9,
            width: AppFonts.title(context) * 9,
          ),
          // recommend_container
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
              SizedBox(height: AppFonts.title(context)),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "편안한 ${type == ResultType.sleep ? "기상 시간" : "취침 시간"} 추천",
                  style: TextStyle(
                    fontSize: AppFonts.title(context),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.containerPrimary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    // 상단 3개 추천 시간
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(3, (index) {
                        return _RecommendationItem(
                          cycle: index + 1,
                          time: recommendedTimes[index],
                        );
                      }),
                    ),
                    // 중간 구분선
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 15.0),
                      decoration: const BoxDecoration(
                        color: AppColors.buttonSecondary,
                      ),
                    ),
                    // 하단 3개 추천 시간
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(3, (index) {
                        return _RecommendationItem(
                          cycle: index + 4,
                          time: recommendedTimes[index + 3],
                        );
                      }),
                    ),
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

// 추천 시간 아이템 표시 위젯
class _RecommendationItem extends StatelessWidget {
  final int cycle;
  final DateTime time;

  const _RecommendationItem({required this.cycle, required this.time});

  // 사이클에 따라 다른 아이콘 파일 경로를 반환하는 함수
  String _getEmojiForCycle(int cycle) {
    switch (cycle) {
      case 1:
      case 2:
        return 'assets/images/icons/frown.svg';
      case 3:
      case 4:
        return 'assets/images/icons/meh.svg';
      case 5:
      case 6:
      default:
        return 'assets/images/icons/smile.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    // DateTime 객체를 '오전/오후 hh:mm' 형식의 문자열로 변환
    final formattedTime = DateFormat('a hh:mm', 'ko_KR').format(time);

    return Column(
      children: [
        Text(
          '사이클 $cycle',
          style: TextStyle(
            fontSize: AppFonts.body(context) * 0.7,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        SvgPicture.asset(
          _getEmojiForCycle(cycle),
          width: AppFonts.title(context) * 2,
          height: AppFonts.title(context) * 2,
        ),

        const SizedBox(height: 4),
        Text(
          formattedTime,
          style: TextStyle(
            fontSize: AppFonts.body(context) * 0.9,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
