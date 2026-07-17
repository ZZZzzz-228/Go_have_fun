import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../shared/widgets/app_ui.dart';
import '../../domain/entities/location_entity.dart';

/// Профиль пользователя с мини-картой и кнопками действий.
class UserProfileSheet extends StatelessWidget {
  final MapUserEntity user;
  final LatLng? myLocation;
  final VoidCallback onMessage;
  final VoidCallback? onMatch;
  final VoidCallback? onSkip;

  const UserProfileSheet({
    super.key,
    required this.user,
    this.myLocation,
    required this.onMessage,
    this.onMatch,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final mascot = user.isFemale ? '👩' : '👨';
    final gradient = user.isFemale
        ? const LinearGradient(
            colors: [AppColors.femaleGlowStart, AppColors.femaleGlowEnd],
          )
        : const LinearGradient(
            colors: [AppColors.maleGlowStart, AppColors.maleGlowEnd],
          );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Аватар
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.match.withValues(alpha: 0.3),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(mascot, style: const TextStyle(fontSize: 42)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${user.name}, ${user.age}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '~${user.distanceMeters.round()} м · ${user.beaconDisplay}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted(context),
                    ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Обновлено ${TimeUtils.timeAgo(user.lastSeen)}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Мини-карта
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 120,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: user.latLng,
                      initialZoom: 16,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: Theme.of(context).brightness ==
                                Brightness.dark
                            ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                            : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.gohavefun.app',
                      ),
                      if (myLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: myLocation!,
                              width: 16,
                              height: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            Marker(
                              point: user.latLng,
                              width: 16,
                              height: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.match,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Кнопки действий — 2 ряда
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Написать',
                      emoji: '💬',
                      onTap: onMessage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'МЭТЧ',
                      emoji: '✨',
                      isMatch: true,
                      onTap: onMatch ?? onMessage,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: 'Пропустить',
                      icon: Icons.skip_next_rounded,
                      isOutlined: true,
                      onTap: onSkip ?? () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Профиль',
                icon: Icons.person_rounded,
                isOutlined: true,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
