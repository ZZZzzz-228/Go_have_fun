import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../shared/widgets/app_ui.dart';

class SearchTimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final VoidCallback onStop;

  const SearchTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.onStop,
  });

  double get _progress {
    const total = 2 * 60 * 60;
    return remainingSeconds / total;
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = TimeUtils.formatSeconds(remainingSeconds);

    return MapOverlayPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Поиск активен',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textMain(context),
                      ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 4,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            timeStr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onStop,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.stop_rounded,
                color: AppColors.textMuted(context),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
