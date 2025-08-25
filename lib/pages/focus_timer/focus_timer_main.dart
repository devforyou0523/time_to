import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_colors.dart';
import '../../widgets/svg_with_shadow.dart';
import '../../theme/app_fonts.dart';
import 'focus_timer_runner.dart';

// Key 관리용 클래스
class CycleWidgetKeys {
  final GlobalKey cycleNumberKey = GlobalKey();
  final GlobalKey cycleLabelKey = GlobalKey();
  final GlobalKey timeTextKey = GlobalKey();
}

class FocusTimerPage extends StatefulWidget {
  const FocusTimerPage({super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage> {
  // 상태 변수
  int _selectedCycle = 4; // 기본 4 사이클

  final _cycleWidgetKeys = CycleWidgetKeys();
  final PageController _pageController =
      PageController(); // ✅ 2. PageController 추가

  @override
  void dispose() {
    _pageController.dispose(); // ✅ 3. dispose 추가
    super.dispose();
  }

  // 도움말 다이얼로그
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
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
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
                              '집중 타이머의 작동 방식은?',
                              style: TextStyle(
                                fontSize: AppFonts.body(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: AppFonts.title(context)),
                            Text(
                              '- 25분 집중과 5분 휴식이 한 사이클로 구성되어 있는 \'뽀모도로 타이머\' 방식을 이용하였습니다.\n\n'
                              '- 기본적인 뽀모도로 타이어는 4 사이클 (2시간) 으로 이루어져 있지만, 이 앱에서는 자유롭게 조절 가능합니다.',
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

  // 사이클 선택 다이얼로그 표시 함수
  // 사이클 선택 다이얼로그 표시 함수 (시간 텍스트 제거 버전)
  void _showCyclePicker(BuildContext context) {
    final keys = _cycleWidgetKeys;

    (Offset, Size) getWidgetInfo(GlobalKey key) {
      final renderBox = key.currentContext!.findRenderObject() as RenderBox;
      return (renderBox.localToGlobal(Offset.zero), renderBox.size);
    }

    // 시간 텍스트를 더 이상 다이얼로그에 표시하지 않으므로 timeTextKey 관련 값은 사용하지 않습니다.
    final (cycleNumPos, cycleNumSize) = getWidgetInfo(keys.cycleNumberKey);
    final (cycleLabelPos, cycleLabelSize) = getWidgetInfo(keys.cycleLabelKey);

    // 사이클 데이터 (1~8 사이클, 30분 단위)
    final cycles = List.generate(8, (i) => i + 1);
    final cycleNumberList = cycles.map((c) => c.toString()).toList();

    final cycleController = FixedExtentScrollController(
      initialItem: _selectedCycle - 1,
    );

    showGeneralDialog(
      context: context,
      barrierLabel: 'cycle_picker_dialog',
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(180),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (dialogContext, anim1, anim2) {
        final double wheelHeight = AppFonts.title(dialogContext) * 7;
        const double horizontalPadding = 60.0;
        final double wheelWidth = cycleNumSize.width + horizontalPadding;

        (double, double) calculatePosition(Offset pos, Size size) {
          final top = (pos.dy + size.height / 2) - (wheelHeight / 2);
          final left = pos.dx - (horizontalPadding / 2);
          return (top, left);
        }

        final (cycleTop, cycleLeft) = calculatePosition(
          cycleNumPos,
          cycleNumSize,
        );

        int tempCycle = _selectedCycle;

        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Material(
              type: MaterialType.transparency,
              child: Stack(
                children: [
                  // 다이얼로그 밖 탭 시 확정 후 닫기
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCycle = tempCycle;
                      });
                      Navigator.of(dialogContext).pop();
                    },
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                      child: Container(color: Colors.transparent),
                    ),
                  ),

                  // 사이클 휠 (숫자)
                  Positioned(
                    top: cycleTop,
                    left: cycleLeft,
                    child: _buildCycleWheel(
                      context,
                      cycleNumberList,
                      cycleController,
                      (i) => dialogSetState(() => tempCycle = cycles[i]),
                      AppFonts.title(context) * 1.4,
                      wheelWidth,
                      wheelHeight,
                    ),
                  ),

                  // '사이클' 레이블 (휠 왼쪽에 그대로 표시)
                  Positioned(
                    top: cycleLabelPos.dy,
                    left: cycleLabelPos.dx,
                    child: IgnorePointer(
                      child: SizedBox(
                        height: cycleLabelSize.height,
                        child: Text(
                          '사이클',
                          style: TextStyle(
                            fontSize: AppFonts.title(context) * 1.4,
                            fontWeight: FontWeight.w200,
                            color: AppColors.textPrimary,
                          ),
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
  Widget _buildCycleWheel(
    BuildContext context,
    List<String> items,
    FixedExtentScrollController controller,
    ValueChanged<int> onSelectedItemChanged,
    double selectedFontSize,
    double width,
    double height,
  ) {
    return SizedBox(
      width: width,
      height: height,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: AppFonts.title(context) * 2.5,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelectedItemChanged,
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

  // 메인 컨텐츠 렌더 함수
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSetupView(), // 설정 화면
        FocusTimerRunnerPage(
          // 타이머 실행 화면
          totalCycles: _selectedCycle,
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

  Widget _buildSetupView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 메인 타이틀
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '집중 타이머',
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

          // 메인 이미지
          svgWithShadow(
            assetName: "assets/images/focus.svg",
            height: AppFonts.title(context) * 12,
            width: AppFonts.title(context) * 12,
          ),

          // 집중 시간 선택 섹션
          const _SectionTitle(title: '내가 집중할 시간은?'),
          _CycleDisplayCard(
            keys: _cycleWidgetKeys,
            selectedCycle: _selectedCycle,
            onTap: () => _showCyclePicker(context),
          ),
          SizedBox(height: AppFonts.title(context) * 3),

          // 시작 버튼
          Column(
            children: [
              IconButton(
                onPressed: () {
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: SvgPicture.asset(
                  'assets/images/icons/start_button.svg',
                  width: AppFonts.title(context) * 3,
                  height: AppFonts.title(context) * 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '눌러서 집중 타이머 시작하기',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppFonts.body(context) * 0.9,
                ),
              ),
            ],
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

// 섹션 타이틀 위젯
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: AppFonts.body(context),
          ),
        ),
      ),
    );
  }
}

// 사이클 표시 카드 위젯
class _CycleDisplayCard extends StatelessWidget {
  final CycleWidgetKeys keys;
  final int selectedCycle;
  final VoidCallback onTap;

  const _CycleDisplayCard({
    required this.keys,
    required this.selectedCycle,
    required this.onTap,
  });

  String _formatTime(int cycle) {
    final totalMinutes = cycle * 30;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '$hours시간 $minutes분';
    } else if (hours > 0) {
      return '$hours시간';
    } else {
      return '$minutes분';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: AppFonts.title(context) * 4,
        padding: EdgeInsets.symmetric(horizontal: AppFonts.title(context)),
        decoration: BoxDecoration(
          color: AppColors.containerPrimary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            // 숫자와 '사이클' 텍스트를 Row로 묶어 개별 Key 할당
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$selectedCycle',
                  key: keys.cycleNumberKey,
                  style: TextStyle(
                    fontSize: AppFonts.title(context) * 1.4,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8), // 숫자와 글자 사이 간격
                Text(
                  '사이클',
                  key: keys.cycleLabelKey,
                  style: TextStyle(
                    fontSize: AppFonts.title(context) * 1.4,
                    fontWeight: FontWeight.w200,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            // 남은 공간을 모두 차지하는 Spacer
            const Spacer(),
            Text(
              '(${_formatTime(selectedCycle)})',
              key: keys.timeTextKey,
              style: TextStyle(
                fontSize: AppFonts.title(context) * 1,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
