import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';

import 'sleep_timer_main.dart';

class ResultView extends StatelessWidget {
  final TimeSelection sleepTime;
  final TimeSelection wakeTime;
  final VoidCallback onBack;

  const ResultView({
    super.key,
    required this.sleepTime,
    required this.wakeTime,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '설정된 수면 시간',
            style: TextStyle(
              fontSize: AppFonts.title(context) * 1.2,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 50),
          _buildTimeInfo(context, '🌙 잠들 시간', sleepTime.toString()),
          const SizedBox(height: 20),
          _buildTimeInfo(context, '☀️ 일어날 시간', wakeTime.toString()),
          const SizedBox(height: 70),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            onPressed: onBack,
            child: Text(
              '돌아가기',
              style: TextStyle(
                fontSize: AppFonts.body(context),
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(BuildContext context, String label, String time) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppFonts.body(context),
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          time,
          style: TextStyle(
            fontSize: AppFonts.title(context),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}