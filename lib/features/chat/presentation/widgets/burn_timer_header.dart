import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_utils.dart';

class BurnTimerHeader extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;
  final String partnerName;
  final VoidCallback onBack;
  final VoidCallback onReport;

  const BurnTimerHeader({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.partnerName,
    required this.onBack,
    required this.onReport,
  });

  Color get _timerColor {
    final progress = secondsRemaining / totalSeconds;
    if (progress > 0.5) return AppColors.timerGreen;
    if (progress > 0.25) return AppColors.timerYellow;
    if (progress > 0.1) return AppColors.timerOrange;
    return AppColors.timerRed;
  }

  bool get _isBurning =>
      secondsRemaining <= AppConstants.burnZoneSeconds;

  @override
  Widget build(BuildContext context) {
    final timeStr = TimeUtils.formatSeconds(secondsRemaining);
    final progress = totalSeconds > 0 ? secondsRemaining / totalSeconds : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: _isBurning
            ? AppColors.timerRed.withOpacity(0.08)
            : AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: _isBurning
                ? AppColors.timerRed.withOpacity(0.3)
                : AppColors.surfaceVariant,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Назад
                  GestureDetector(
                    onTap: onBack,
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Имя партнёра
                  Expanded(
                    child: Text(
                      partnerName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Таймер
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 500),
                    style: TextStyle(
                      color: _timerColor,
                      fontSize: _isBurning ? 22 : 18,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isBurning)
                          const Text('🔥 '),
                        Text(timeStr),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Жалоба
                  GestureDetector(
                    onTap: onReport,
                    child: const Icon(
                      Icons.flag_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Прогресс-бар горения
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  height: 4,
                  width: double.infinity,
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
