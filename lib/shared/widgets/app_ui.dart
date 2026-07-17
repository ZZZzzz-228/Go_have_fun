import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// Мягкая карточка: скругление, тень, лёгкий градиент по желанию.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? tint;
  final double radius;
  final bool glow;
  final bool gradient;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.tint,
    this.radius = 20,
    this.glow = false,
    this.gradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: padding,
          decoration: AppColors.softCard(
            context: context,
            tint: tint,
            radius: radius,
            glow: glow,
            gradient: gradient,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Крупная цветная кнопка-плашка с иконкой.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? emoji;
  final bool isMatch;
  final bool isOutlined;
  final bool isLoading;
  final bool expanded;
  final Color? color;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.emoji,
    this.isMatch = false,
    this.isOutlined = false,
    this.isLoading = false,
    this.expanded = true,
    this.color,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressCtrl.forward();
  void _onTapUp(TapUpDetails _) => _pressCtrl.reverse();
  void _onTapCancel() => _pressCtrl.reverse();

  void _handleTap() {
    if (widget.onTap == null || widget.isLoading) return;
    HapticFeedback.lightImpact();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.isMatch
        ? AppColors.matchGradient
        : AppColors.primaryGradient;
    final bgColor = widget.color ?? AppColors.primary;

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.isLoading)
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        else ...[
          if (widget.emoji != null) ...[
            Text(widget.emoji!, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
          ] else if (widget.icon != null) ...[
            Icon(widget.icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: widget.isOutlined
                        ? (widget.color ?? AppColors.primary)
                        : Colors.white,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );

    final child = AnimatedBuilder(
      animation: _scale,
      builder: (_, c) => Transform.scale(scale: _scale.value, child: c),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          padding: widget.expanded
              ? null
              : const EdgeInsets.symmetric(horizontal: 20),
          decoration: widget.isOutlined
              ? BoxDecoration(
                  color: AppColors.cardBg(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.color ?? AppColors.primary,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : BoxDecoration(
                  gradient: widget.color == null ? gradient : null,
                  color: widget.color,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isMatch ? AppColors.match : bgColor)
                          .withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
          child: Center(child: content),
        ),
      ),
    );

    return widget.expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}

/// Компактная круглая кнопка поверх карты.
class AppMapFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool gradient;
  final String? tooltip;

  const AppMapFab({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.gradient = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final child = GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: gradient ? AppColors.primaryGradient : null,
          color: gradient
              ? null
              : (color ?? (isDark ? AppColors.darkSurface : AppColors.surface)),
          shape: BoxShape.circle,
          border: gradient
              ? null
              : Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: gradient ? Colors.white : AppColors.textMain(context),
          size: 24,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: child);
    }
    return child;
  }
}

/// Полупрозрачная панель поверх карты.
class MapOverlayPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool blur;

  const MapOverlayPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.radius = 20,
    this.blur = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.88)
              : AppColors.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: isDark
                ? AppColors.borderDark.withValues(alpha: 0.6)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
