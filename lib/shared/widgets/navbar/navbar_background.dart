import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Фон навбара — liquid-glass superellipse-контейнер.
/// Адаптация из LiquidGlass-NavBar.
class NavbarBackground extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final Color tint;

  const NavbarBackground({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.tint = const Color(0xFF7C3AED),
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLayer(
      settings: const LiquidGlassSettings(thickness: 18, blur: 6),
      child: LiquidGlass(
        shape: LiquidRoundedSuperellipse(borderRadius: 26),
        child: Container(
          width: width.w,
          height: height.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
