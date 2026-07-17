import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/location_entity.dart';

/// Крупный кликабельный маскот на карте с пульсацией и бейджами.
class MapUserMarker extends StatefulWidget {
  final MapUserEntity user;
  final VoidCallback onTap;

  const MapUserMarker({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  State<MapUserMarker> createState() => _MapUserMarkerState();
}

class _MapUserMarkerState extends State<MapUserMarker>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _wobbleCtrl;
  late Animation<double> _pulse;
  late Animation<double> _wobble;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _wobbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _wobble = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _wobbleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _wobbleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final gradient = user.isFemale
        ? const LinearGradient(
            colors: [AppColors.femaleGlowStart, AppColors.femaleGlowEnd],
          )
        : const LinearGradient(
            colors: [AppColors.maleGlowStart, AppColors.maleGlowEnd],
          );
    final mascot = user.isFemale ? '👩' : '👨';

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulse, _wobble]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _wobble.value,
            child: Transform.scale(
              scale: _pulse.value,
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Пульсирующее кольцо
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.match.withValues(
                      alpha: 0.12 * (1 - _pulseCtrl.value),
                    ),
                  ),
                ),
                // Аватар-маскот
                Positioned(
                  left: 6,
                  top: 6,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.match.withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 1,
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
                              mascot,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                  ),
                ),
                // Бейдж батареи
                if (user.batteryLevel != null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: _Badge(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _batteryIcon(user.batteryLevel!),
                            size: 10,
                            color: _batteryColor(user.batteryLevel!),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${user.batteryLevel}%',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Стрелка направления
                if (user.headingDegrees != null)
                  Positioned(
                    left: -4,
                    bottom: 8,
                    child: Transform.rotate(
                      angle: user.headingDegrees! * math.pi / 180,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.navigation_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Имя + статус
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface.withValues(alpha: 0.92)
                    : AppColors.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      color: AppColors.textMain(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    user.beaconEmoji ?? '${user.distanceMeters.round()} м',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _batteryIcon(int level) {
    if (level > 80) return Icons.battery_full_rounded;
    if (level > 50) return Icons.battery_5_bar_rounded;
    if (level > 20) return Icons.battery_3_bar_rounded;
    return Icons.battery_alert_rounded;
  }

  Color _batteryColor(int level) {
    if (level > 50) return AppColors.success;
    if (level > 20) return AppColors.warning;
    return AppColors.error;
  }
}

class _Badge extends StatelessWidget {
  final Widget child;
  const _Badge({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }
}
