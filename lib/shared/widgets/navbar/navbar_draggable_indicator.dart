import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Перетаскиваемый «каплевидный» индикатор.
/// Прямой порт из LiquidGlass-NavBar с небольшой адаптацией под
/// светлую тему (видимая primary-заливка).
class NavbarDraggableIndicator extends StatelessWidget {
  final double position;          // X-центр индикатора
  final double baseSize;          // базовая ширина (для 3 items)
  final int itemCount;
  final List<double> snapPositions;
  final Function(double) onDragUpdate;
  final Function(int) onDragEnd;
  final double bottomOffset;
  final Color tint;

  const NavbarDraggableIndicator({
    super.key,
    required this.position,
    required this.baseSize,
    required this.itemCount,
    required this.snapPositions,
    required this.onDragUpdate,
    required this.onDragEnd,
    this.bottomOffset = 12,
    this.tint = const Color(0xFF7C3AED),
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = 1.sw;
    final adaptiveWidth = (baseSize * (3.5 / itemCount).clamp(1, 1.2)).w;

    final clampedCenter = position.clamp(
      adaptiveWidth / 2,
      screenWidth - adaptiveWidth / 2,
    );

    return Positioned(
      left: clampedCenter - adaptiveWidth / 2,
      bottom: bottomOffset.h + 4.h,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          final newPos = (position + details.delta.dx).clamp(
            adaptiveWidth / 2,
            screenWidth - adaptiveWidth / 2,
          );
          onDragUpdate(newPos);
        },
        onHorizontalDragEnd: (_) {
          if (snapPositions.isEmpty) return;
          double closest = snapPositions.first;
          double minDist = (position - closest).abs();
          for (final p in snapPositions) {
            final d = (position - p).abs();
            if (d < minDist) {
              minDist = d;
              closest = p;
            }
          }
          onDragEnd(snapPositions.indexOf(closest));
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 250),
          scale: 1.0,
          child: LiquidGlassLayer(
            settings: const LiquidGlassSettings(
              thickness: 16,
              blur: 4,
              lightIntensity: 1.4,
            ),
            child: LiquidStretch(
              stretch: 0.6,
              interactionScale: 1.04,
              child: LiquidGlass(
                glassContainsChild: true,
                shape: LiquidRoundedSuperellipse(borderRadius: 24),
                child: GlassGlow(
                  child: Container(
                    width: adaptiveWidth,
                    height: 58.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          tint.withValues(alpha: 0.16),
                          tint.withValues(alpha: 0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        (adaptiveWidth / 2).r,
                      ),
                      border: Border.all(
                        color: tint.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
