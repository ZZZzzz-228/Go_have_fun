import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SafeZoneInfoWidget extends StatelessWidget {
  final String name;
  final String emoji;
  final String distance;

  const SafeZoneInfoWidget({
    super.key,
    required this.name,
    required this.emoji,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.safeZone.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.safeZone.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        size: 12, color: AppColors.safeZone),
                    const SizedBox(width: 4),
                    const Text(
                      'Безопасная зона · ',
                      style: TextStyle(
                          color: AppColors.safeZone, fontSize: 12),
                    ),
                    Text(
                      distance,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
