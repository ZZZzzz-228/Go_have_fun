import 'package:flutter/material.dart';

/// Яркая молодёжная палитра: карта — центр, акценты для МЭТЧ и действий.
class AppColors {
  AppColors._();

  // ===== Бренд / МЭТЧ =====
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5A4BD1);
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color match = Color(0xFFFF3366);
  static const Color matchGlow = Color(0xFFFF6B9D);
  /// Alias для совместимости с ColorScheme.tertiary
  static const Color tertiary = match;
  static const Color accent = Color(0xFF00D9A5);
  static const Color accentAlt = Color(0xFFFFBE0B);

  // ===== Светлая тема =====
  static const Color background = Color(0xFFF5F3FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEDE9FE);
  static const Color surfaceVariant = Color(0xFFF0ECFF);
  static const Color mapOverlayLight = Color(0xE6FFFFFF);

  // ===== Тёмная тема =====
  static const Color darkBackground = Color(0xFF0D0B1A);
  static const Color darkSurface = Color(0xFF1A1730);
  static const Color darkSurfaceAlt = Color(0xFF252140);
  static const Color mapOverlayDark = Color(0xCC0D0B1A);

  // ===== Обводки / тени =====
  static const Color border = Color(0xFFE8E4F0);
  static const Color borderStrong = Color(0xFFD4CEE8);
  static const Color borderDark = Color(0xFF3D3658);
  static const Color overlay = Color(0x18000000);

  // Legacy glass (совместимость)
  static const Color glassLight = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x33C9A8FF);
  static const Color glassDark = Color(0xCC0A0514);

  // ===== Текст =====
  static const Color textPrimary = Color(0xFF1A1033);
  static const Color textSecondary = Color(0xFF6B6280);
  static const Color textDisabled = Color(0xFFA8A0B8);
  static const Color textPrimaryDark = Color(0xFFF5F0FF);
  static const Color textSecondaryDark = Color(0xFFB8B0CC);

  // ===== Статусы =====
  static const Color success = Color(0xFF00D9A5);
  static const Color error = Color(0xFFFF4757);
  static const Color warning = Color(0xFFFFBE0B);
  static const Color info = Color(0xFF54A0FF);

  // ===== Таймер =====
  static const Color timerGreen = success;
  static const Color timerYellow = warning;
  static const Color timerOrange = Color(0xFFFF8C42);
  static const Color timerRed = error;

  // ===== Карта =====
  static const Color mapHeatLow = Color(0x336C5CE7);
  static const Color mapHeatMid = Color(0x66FF6B9D);
  static const Color mapHeatHigh = Color(0xAAFF3366);
  static const Color safeZone = accent;
  static const Color activeUser = primary;
  static const Color inactiveUser = textSecondary;

  static const Color femaleGlowStart = Color(0xFFFF6B9D);
  static const Color femaleGlowEnd = Color(0xFFFF3366);
  static const Color maleGlowStart = Color(0xFF6C5CE7);
  static const Color maleGlowEnd = Color(0xFF54A0FF);

  // ===== Пара =====
  static const Color coupleGold = Color(0xFFFFBE0B);
  static const Color couplePink = secondary;
  static const Color stampInk = textPrimary;

  // ===== Градиенты =====
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient matchGradient = LinearGradient(
    colors: [Color(0xFFFF3366), Color(0xFFFF6B9D), Color(0xFFFFBE0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF5A4BD1), Color(0xFF6C5CE7), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D0B1A), Color(0xFF1A1730), Color(0xFF252140)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient burnGradient = LinearGradient(
    colors: [Color(0xFFFF4757), Color(0xFFFF8C42)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient glassGradient({double opacity = 1}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.14 * opacity),
        surfaceVariant.withValues(alpha: 0.55 * opacity),
        const Color(0xFF0A0514).withValues(alpha: 0.75 * opacity),
      ],
      stops: const [0.0, 0.45, 1.0],
    );
  }

  /// Мягкая карточка с тенью и скруглением.
  static BoxDecoration softCard({
    required BuildContext context,
    Color? tint,
    double radius = 20,
    bool glow = false,
    bool gradient = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = tint ?? (isDark ? darkSurface : surface);
    final borderColor = isDark ? borderDark : border;

    return BoxDecoration(
      gradient: gradient ? primaryGradient : null,
      color: gradient ? null : base,
      borderRadius: BorderRadius.circular(radius),
      border: gradient ? null : Border.all(color: borderColor, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
        if (glow)
          BoxShadow(
            color: match.withValues(alpha: 0.18),
            blurRadius: 28,
            spreadRadius: -4,
          ),
      ],
    );
  }

  /// Legacy alias.
  static BoxDecoration modernCard({
    Color? tint,
    double radius = 20,
    bool glow = false,
  }) {
    final base = tint ?? surface;
    return BoxDecoration(
      color: base,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        if (glow)
          BoxShadow(
            color: primary.withValues(alpha: 0.10),
            blurRadius: 24,
            spreadRadius: -4,
          ),
      ],
    );
  }

  static Color scaffoldBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBackground
          : background;

  static Color cardBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : surface;

  static Color textMain(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textPrimaryDark
          : textPrimary;

  static Color textMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textSecondaryDark
          : textSecondary;
}
