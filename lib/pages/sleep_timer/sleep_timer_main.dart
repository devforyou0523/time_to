import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_colors.dart';
import '../../widgets/svg_with_shadow.dart';
import '../../theme/app_fonts.dart';
import 'sleep_timer_result.dart';

// 시간 위젯의 Key 관리용 클래스
class TimeWidgetKeys {
  final GlobalKey periodKey = GlobalKey();
  final GlobalKey hourKey = GlobalKey();
  final GlobalKey minuteKey = GlobalKey();
  final GlobalKey hourLabelKey = GlobalKey();
  final GlobalKey minuteLabelKey = GlobalKey();
}

// 선택된 시간 데이터 클래스
class TimeSelection {
  String period;
  int hour;
  int minute;

  TimeSelection({
    required this.period,
    required this.hour,
    required this.minute,
  });

  @override
  String toString() {
    return '$period ${hour.toString().padLeft(2, '0')}시 ${minute.toString().padLeft(2, '0')}분';
  }
}

class SleepTimerPage extends StatefulWidget {
  const SleepTimerPage({super.key});

  @override
  State<SleepTimerPage> createState() => _SleepTimerPageState();
}

class _SleepTimerPageState extends State<SleepTimerPage> {
  // 상태 변수
  TimeSelection _sleepTime = TimeSelection(period: "오후", hour: 10, minute: 30);
  TimeSelection _wakeTime = TimeSelection(period: "오전", hour: 9, minute: 0);

  final _sleepTimeKeys = TimeWidgetKeys();
  final _wakeTimeKeys = TimeWidgetKeys();

  final PageController _pageController = PageController();

  ResultType? _selectedType;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

  // 시간 선택 다이얼로그 표시 함수
  void _showTimePicker(BuildContext context, {required bool isSleepTime}) {
    final keys = isSleepTime ? _sleepTimeKeys : _wakeTimeKeys;

    (Offset, Size) getWidgetInfo(GlobalKey key) {
      final renderBox = key.currentContext!.findRenderObject() as RenderBox;
      return (renderBox.localToGlobal(Offset.zero), renderBox.size);
    }

    final (periodPos, periodSize) = getWidgetInfo(keys.periodKey);
    final (hourPos, hourSize) = getWidgetInfo(keys.hourKey);
    final (minutePos, minuteSize) = getWidgetInfo(keys.minuteKey);
    final (hourLabelPos, _) = getWidgetInfo(keys.hourLabelKey);
    final (minuteLabelPos, _) = getWidgetInfo(keys.minuteLabelKey);

    TimeSelection tempTime = isSleepTime ? _sleepTime : _wakeTime;

    final periodController = FixedExtentScrollController(
      initialItem: tempTime.period == "오전" ? 0 : 1,
    );
    final hourController = FixedExtentScrollController(
      initialItem: tempTime.hour - 1,
    );
    final minuteController = FixedExtentScrollController(
      initialItem: tempTime.minute ~/ 10,
    );

    final periods = ["오전", "오후"];
    final hours = List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
    final minutes = List.generate(
      6,
      (i) => (i * 10).toString().padLeft(2, '0'),
    );

    showGeneralDialog(
      context: context,
      barrierLabel: 'time_picker_dialog',
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(180),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (dialogContext, anim1, anim2) {
        final double wheelHeight = AppFonts.title(dialogContext) * 7;
        final double periodWheelWidth = periodSize.width * 1.5;
        final double hourWheelWidth = hourSize.width * 1.5;
        final double minuteWheelWidth = minuteSize.width * 1.5;

        (double, double) calculatePosition(
          Offset pos,
          Size size,
          double wheelWidth,
        ) {
          final top = (pos.dy + size.height / 2) - (wheelHeight / 2);
          final left = (pos.dx + size.width / 2) - (wheelWidth / 2);
          return (top, left);
        }

        final (periodTop, periodLeft) = calculatePosition(
          periodPos,
          periodSize,
          periodWheelWidth,
        );
        final (hourTop, hourLeft) = calculatePosition(
          hourPos,
          hourSize,
          hourWheelWidth,
        );
        final (minuteTop, minuteLeft) = calculatePosition(
          minutePos,
          minuteSize,
          minuteWheelWidth,
        );

        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Material(
              type: MaterialType.transparency,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSleepTime) {
                          _sleepTime = tempTime;
                        } else {
                          _wakeTime = tempTime;
                        }
                      });
                      Navigator.of(dialogContext).pop();
                    },
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  Positioned(
                    top: periodTop,
                    left: periodLeft,
                    child: _buildTimeWheel(
                      context,
                      periods,
                      periodController,
                      (i) => tempTime.period = periods[i],
                      AppFonts.title(context),
                      dialogSetState,
                      periodWheelWidth,
                    ),
                  ),
                  Positioned(
                    top: hourTop,
                    left: hourLeft,
                    child: _buildTimeWheel(
                      context,
                      hours,
                      hourController,
                      (i) => tempTime.hour = int.parse(hours[i]),
                      AppFonts.title(context) * 1.4,
                      dialogSetState,
                      hourWheelWidth,
                    ),
                  ),
                  Positioned(
                    top: minuteTop,
                    left: minuteLeft,
                    child: _buildTimeWheel(
                      context,
                      minutes,
                      minuteController,
                      (i) => tempTime.minute = int.parse(minutes[i]),
                      AppFonts.title(context) * 1.4,
                      dialogSetState,
                      minuteWheelWidth,
                    ),
                  ),
                  Positioned(
                    top: hourLabelPos.dy,
                    left: hourLabelPos.dx,
                    child: IgnorePointer(
                      child: Text(
                        "시 ",
                        style: TextStyle(
                          fontSize: AppFonts.title(context) * 1.4,
                          fontWeight: FontWeight.w200,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: minuteLabelPos.dy,
                    left: minuteLabelPos.dx,
                    child: IgnorePointer(
                      child: Text(
                        "분",
                        style: TextStyle(
                          fontSize: AppFonts.title(context) * 1.4,
                          fontWeight: FontWeight.w200,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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

  // 스크롤 휠 위젯 빌드 함수
  Widget _buildTimeWheel(
    BuildContext context,
    List<String> items,
    FixedExtentScrollController controller,
    ValueChanged<int> onSelectedItemChanged,
    double selectedFontSize,
    StateSetter dialogSetState,
    double width,
  ) {
    return SizedBox(
      width: width,
      height: AppFonts.title(context) * 7,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: AppFonts.title(context) * 2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          onSelectedItemChanged(index);
          dialogSetState(() {});
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final isSelected =
                controller.hasClients && controller.selectedItem == index;
            return GestureDetector(
              onTap: () => controller.animateToItem(
                index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              ),
              behavior: HitTestBehavior.translucent,
              child: Center(
                child: Text(
                  items[index],
                  style: TextStyle(
                    fontSize: isSelected
                        ? selectedFontSize
                        : selectedFontSize * 0.8,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withAlpha(180),
                  ),
                ),
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  // 메인 위젯 빌드 함수
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        _buildTimerSelectionView(),
        if (_selectedType != null)
          ResultView(
            sleepTime: _sleepTime,
            wakeTime: _wakeTime,
            type: _selectedType!, // ✅ Sleep/Wake 구분
            onBack: () {
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
      ],
    );
  }

  // 시간 선택 화면 빌드 함수
  Widget _buildTimerSelectionView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
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
                onPressed: () => _showHelp(context),
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

          GestureDetector(
            onTap: () {
              setState(() => _selectedType = ResultType.sleep);
              _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const _TimeSectionTitle(title: '내가 잠에 들 시간은?'),
          ),

          _TimeDisplayCard(
            time: _sleepTime,
            keys: _sleepTimeKeys,
            onTap: () => _showTimePicker(context, isSleepTime: true),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: AppFonts.body(context) * 0.8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '또는',
                style: TextStyle(
                  fontSize: AppFonts.body(context) * 0.8,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              setState(() => _selectedType = ResultType.wake);
              _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const _TimeSectionTitle(title: '내가 일어날 시간은?'),
          ),
          _TimeDisplayCard(
            time: _wakeTime,
            keys: _wakeTimeKeys,
            onTap: () => _showTimePicker(context, isSleepTime: false),
          ),
        ],
      ),
    );
  }
}

// 섹션 타이틀 위젯
class _TimeSectionTitle extends StatelessWidget {
  final String title;
  const _TimeSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
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
    );
  }
}

// 시간 표시 카드 위젯
class _TimeDisplayCard extends StatelessWidget {
  final TimeSelection time;
  final TimeWidgetKeys keys;
  final VoidCallback onTap;

  const _TimeDisplayCard({
    required this.time,
    required this.keys,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Text(
              time.period,
              key: keys.periodKey,
              style: TextStyle(fontSize: AppFonts.title(context)),
            ),
            Row(
              children: [
                UnderlinedTextWithSpacing(
                  key: keys.hourKey,
                  text: time.hour.toString().padLeft(2, '0'),
                ),
                Text(
                  "시 ",
                  key: keys.hourLabelKey,
                  style: TextStyle(
                    fontSize: AppFonts.title(context) * 1.4,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                UnderlinedTextWithSpacing(
                  key: keys.minuteKey,
                  text: time.minute.toString().padLeft(2, '0'),
                ),
                Text(
                  "분",
                  key: keys.minuteLabelKey,
                  style: TextStyle(
                    fontSize: AppFonts.title(context) * 1.4,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 밑줄 텍스트 위젯
class UnderlinedTextWithSpacing extends StatelessWidget {
  final String text;
  const UnderlinedTextWithSpacing({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
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
          bottom: 0,
          child: Container(height: 3, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
