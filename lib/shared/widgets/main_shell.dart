import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RouteNames.map)) return 0;
    if (location.startsWith(RouteNames.chatsList)) return 1;
    if (location.startsWith(RouteNames.profile)) return 2;
    if (location.startsWith(RouteNames.couple)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: _LiquidGlassBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.location_on_outlined,
                activeIcon: Icons.location_on,
                label: 'карта',
                isActive: currentIndex == 0,
                onTap: () => context.go(RouteNames.map),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline_rounded,
                activeIcon: Icons.chat_bubble_rounded,
                label: 'чаты',
                isActive: currentIndex == 1,
                onTap: () => context.go(RouteNames.chatsList),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'ты',
                isActive: currentIndex == 2,
                onTap: () => context.go(RouteNames.profile),
              ),
              _NavItem(
                icon: Icons.favorite_outline_rounded,
                activeIcon: Icons.favorite_rounded,
                label: 'пара',
                isActive: currentIndex == 3,
                onTap: () => context.go(RouteNames.couple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// «Жидкое стекло» — блюр фона + прозрачные слои + мягкая подсветка по
/// краям, имитирующая преломление света на стеклянной панели (в духе
/// iOS "Liquid Glass"). Настоящий фрагментный шейдер с картой смещений
/// (feDisplacementMap, как в вебе) в Flutter поверх реального фона
/// панелей не используется — вместо этого линзу имитируют слои блюра,
/// градиентов и бликов, что даёт очень похожий визуальный результат
/// и работает стабильно на всех платформах.
class _LiquidGlassBar extends StatelessWidget {
  final Widget child;
  const _LiquidGlassBar({required this.child});

  @override
  Widget build(BuildContext context) {
    const radius = 28.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.10),
                const Color(0xFF14141A).withOpacity(0.58),
                const Color(0xFF14141A).withOpacity(0.82),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.16),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Тонкий световой блик сверху — как отражение на кромке стекла
              Positioned(
                left: 12,
                right: 12,
                top: 1,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.white : const Color(0xFF7A7A85);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
