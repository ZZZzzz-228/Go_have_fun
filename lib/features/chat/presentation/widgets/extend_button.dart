import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExtendButton extends StatelessWidget {
  final bool myWantsExtend;
  final bool partnerWantsExtend;
  final VoidCallback onExtend;

  const ExtendButton({
    super.key,
    required this.myWantsExtend,
    required this.partnerWantsExtend,
    required this.onExtend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.timerOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.timerOrange.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⏰ Продлить на 5 минут?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  myWantsExtend
                      ? partnerWantsExtend
                      ? '✅ Оба согласны! Продлено.'
                      : '⏳ Ждём ответа партнёра...'
                      : 'Нажми — и партнёр увидит запрос',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!myWantsExtend)
            GestureDetector(
              onTap: onExtend,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.timerOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '+5 мин',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
