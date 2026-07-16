import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/location_entity.dart';

class MapUserMarker extends StatelessWidget {
  final MapUserEntity user;
  final VoidCallback onTap;

  const MapUserMarker({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Аватар
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: user.isFemale
                  ? AppColors.primaryGradient
                  : const LinearGradient(
                      colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                    ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: (user.isFemale
                          ? AppColors.primary
                          : const Color(0xFF7C4DFF))
                      .withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: user.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.avatarUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      user.isFemale ? '👩' : '👨',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
          ),

          // Маяк-статус (если есть)
          if (user.beaconEmoji != null)
            Container(
              margin: const EdgeInsets.only(top: 3),
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.beaconEmoji!,
                style: const TextStyle(fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}
