import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/svg_with_shadow.dart';

// 타이머 상태 Enum
enum TimerState { running, paused, finished }

enum TimerType { focus, rest }

class FocusTimerRunnerPage extends StatefulWidget {
  final int totalCycles;
  final VoidCallback onBack;

  const FocusTimerRunnerPage({
    super.key,
    required this.totalCycles,
    required this.onBack,
  });

  @override
  State<FocusTimerRunnerPage> createState() => _FocusTimerRunnerPageState();
}

class _FocusTimerRunnerPageState extends State<FocusTimerRunnerPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  TimerState _timerState = TimerState.running;
  TimerType _timerType = TimerType.focus;

  int _currentCycle = 1;
  final int _focusMinutes = 25;
  final int _restMinutes = 5;

  // 남은 시간을 포맷에 맞게 변환하는 getter
  String get _timerString {
    Duration duration = _controller.duration! * _controller.value;
    return '${(duration.inMinutes).toString().padLeft(2, '0')} : ${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: _focusMinutes),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _handleTimerCompletion();
      }
    });

    _startTimer();
  }

  void _handleTimerCompletion() {
    setState(() {
      if (_timerType == TimerType.focus) {
        // 집중 시간이 끝났을 때는 항상 휴식 시간으로 전환
        _timerType = TimerType.rest;
        _controller.duration = Duration(minutes: _restMinutes);
        _startTimer();
      } else {
        // 휴식 시간이 끝났을 때 완료 여부 체크
        if (_currentCycle < widget.totalCycles) {
          // 아직 사이클이 남았다면 다음 집중 시간으로
          _currentCycle++;
          _timerType = TimerType.focus;
          _controller.duration = Duration(minutes: _focusMinutes);
          _startTimer();
        } else {
          // 마지막 사이클의 휴식 시간이 끝났다면 완료 처리
          _timerState = TimerState.finished;
        }
      }
    });
  }

  void _startTimer() {
    _controller.reverse(from: 1.0);
    setState(() {
      _timerState = TimerState.running;
    });
  }

  void _pauseTimer() {
    _controller.stop();
    setState(() {
      _timerState = TimerState.paused;
    });
  }

  void _resumeTimer() {
    _controller.reverse(from: _controller.value);
    setState(() {
      _timerState = TimerState.running;
    });
  }

  void _skipRest() {
    // 휴식 건너뛰기 시에도 완료 여부 체크
    if (_currentCycle < widget.totalCycles) {
      _controller.stop();
      setState(() {
        _currentCycle++;
        _timerType = TimerType.focus;
        _controller.duration = Duration(minutes: _focusMinutes);
        _startTimer();
      });
    } else {
      _controller.stop();
      setState(() {
        _timerState = TimerState.finished;
      });
    }
  }

  // 개발자용 함수 (타이머 3초 설정)
  void _setRemainingTimeDev() {
    _controller.stop();
    // 현재 타이머의 전체 시간을 초 단위로 가져옴
    final totalDurationInSeconds = _controller.duration!.inSeconds;
    // 3초에 해당하는 진행률(0.0 ~ 1.0)을 계산
    final fromValue = 3.0 / totalDurationInSeconds;
    // 계산된 지점부터 타이머를 다시 시작
    _controller.reverse(from: fromValue);
    setState(() {
      _timerState = TimerState.running;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentIconAsset = _timerType == TimerType.focus
        ? "assets/images/focus.svg"
        : "assets/images/rest.svg";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 상단 타이틀
          Row(
            children: [
              const Spacer(), // 왼쪽 공간
              Text(
                '집중 타이머',
                style: TextStyle(
                  fontSize: AppFonts.title(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              // 오른쪽 공간을 차지하며 버튼을 오른쪽에 배치
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.bug_report, color: Colors.white54),
                    onPressed: _setRemainingTimeDev,
                    tooltip: '남은 시간 3초로 설정 (개발자용)',
                  ),
                ),
              ),
            ],
          ),

          // 원형 타이머
          AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 타이머 배경
                CustomPaint(
                  size: const Size.fromRadius(120),
                  painter: TimerPainter(
                    backgroundColor: AppColors.containerPrimary,
                  ),
                ),
                // 타이머 진행률
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size.fromRadius(120),
                      painter: TimerPainter(
                        backgroundColor: Colors.transparent,
                        progress: _controller.value,
                        progressColor: AppColors.buttonPrimary,
                      ),
                    );
                  },
                ),
                // 타이머 내부 컨텐츠
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    svgWithShadow(
                      assetName: currentIconAsset,
                      height: AppFonts.title(context) * 5,
                      width: AppFonts.title(context) * 5,
                    ),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Text(
                          _timerString,
                          style: TextStyle(
                            fontSize: AppFonts.title(context) * 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppFonts.title(context) * 2),
          // 사이클 현황 텍스트
          _buildStatusText(context),
          SizedBox(height: AppFonts.title(context) * 2),
          // 컨트롤 버튼
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusText(BuildContext context) {
    if (_timerState == TimerState.finished) {
      return Text(
        '모든 사이클을 완료하였습니다!',
        style: TextStyle(
          fontSize: AppFonts.body(context),
          fontWeight: FontWeight.w400,
        ),
      );
    }

    String typeText = _timerType == TimerType.focus ? '집중 시간' : '휴식 시간';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${widget.totalCycles}',
          style: TextStyle(
            fontSize: AppFonts.title(context),
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          ' 사이클 중',
          style: TextStyle(
            fontSize: AppFonts.title(context),
            fontWeight: FontWeight.w200,
          ),
        ),
        Text(
          ' $_currentCycle',
          style: TextStyle(
            fontSize: AppFonts.title(context),
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          '번째 $typeText',
          style: TextStyle(
            fontSize: AppFonts.title(context),
            fontWeight: FontWeight.w200,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    if (_timerState == TimerState.finished) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ControlButton(
            iconPath: 'assets/images/icons/stop_button.svg',
            onTap: widget.onBack,
          ),
        ],
      );
    }

    if (_timerState == TimerState.paused) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ControlButton(
            iconPath: 'assets/images/icons/start_button.svg',
            onTap: _resumeTimer,
          ),
          const SizedBox(width: 20),
          _ControlButton(
            iconPath: 'assets/images/icons/stop_button.svg',
            onTap: widget.onBack,
          ),
          if (_timerType == TimerType.rest) ...[
            const SizedBox(width: 20),
            _ControlButton(
              iconPath: 'assets/images/icons/skip_button.svg',
              onTap: _skipRest,
            ),
          ],
        ],
      );
    }

    // Timer is running
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          iconPath: 'assets/images/icons/pause_button.svg',
          onTap: _pauseTimer,
        ),
        if (_timerType == TimerType.rest) ...[
          const SizedBox(width: 20),
          _ControlButton(
            iconPath: 'assets/images/icons/skip_button.svg',
            onTap: _skipRest,
          ),
        ],
      ],
    );
  }
}

// 커스텀 버튼 위젯
class _ControlButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;
  const _ControlButton({required this.iconPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: SvgPicture.asset(
        iconPath,
        width: AppFonts.title(context) * 3,
        height: AppFonts.title(context) * 3,
      ),
    );
  }
}

// 원형 타이머를 그리는 CustomPainter
class TimerPainter extends CustomPainter {
  final Color backgroundColor;
  final Color? progressColor;
  final double progress;

  TimerPainter({
    required this.backgroundColor,
    this.progressColor,
    this.progress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;
    const endPointRadiusIncrease = 3.0; // 원하는 증가량

    // 배경 원
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, backgroundPaint);

    // 진행률 원
    if (progressColor != null) {
      final progressPaint = Paint()
        ..color = progressColor!
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const startAngle = -pi / 2; // 12시 방향에서 시작
      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );

      // 진행률 끝에 원 추가 (크기 키움)
      final progressCenter = Offset(
        center.dx + radius * cos(startAngle + sweepAngle),
        center.dy + radius * sin(startAngle + sweepAngle),
      );
      final endPointPaint = Paint()
        ..color = Colors
            .white // 흰색 원
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        progressCenter,
        strokeWidth / 2 + endPointRadiusIncrease,
        endPointPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is TimerPainter) {
      return oldDelegate.backgroundColor != backgroundColor ||
          oldDelegate.progressColor != progressColor ||
          oldDelegate.progress != progress;
    }
    return true;
  }
}
