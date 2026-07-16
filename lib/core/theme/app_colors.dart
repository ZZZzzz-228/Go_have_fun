import 'package:flutter/material.dart';

/// Палитра Go Have Fun — content-first, светлая тема по умолчанию.
/// Яркие акценты (vivid violet + hot pink) на нейтральной светлой
/// поверхности. Старые имена оставлены, чтобы остальные экраны
/// (chat, auth, friends...) не сломались.
class AppColors {
  AppColors._();

  // ===== Бренд =====
  static const Color primary       = Color(0xFF7C3AED); // vivid violet
  static const Color primaryDark   = Color(0xFF5B21B6);
  static const Color secondary     = Color(0xFFEC4899); // hot pink
  static const Color tertiary      = Color(0xFF5B21B6);

  // ===== Светлые поверхности (основная тема) =====
  static const Color background    = Color(0xFFFAFAFC); // off-white
  static const Color surface       = Color(0xFFFFFFFF); // cards
  static const Color surfaceAlt    = Color(0xFFF4F2F8); // tint
  static const Color surfaceVariant = Color(0xFFF4F2F8);

  // ===== Ночные поверхности (для darkTheme & старых glass-экранов) =====
  static const Color darkBackground = Color(0xFF0A0815);
  static const Color darkSurface    = Color(0xFF13102A);

  // ===== Обводки / тени =====
  static const Color border        = Color(0xFFECEAEF); // очень тонкая светлая
  static const Color borderStrong  = Color(0xFFD8D4DD);
  static const Color overlay       = Color(0x10000000);

  // "Стеклянные" оттенки (для существующих Liquid-glass экранов)
  static const Color glassLight    = Color(0x14FFFFFF);
  static const Color glassBorder   = Color(0x33C9A8FF);
  static const Color glassDark     = Color(0xCC0A0514);

  // ===== Текст =====
  static const Color textPrimary   = Color(0xFF0F0A1F);
  static const Color textSecondary = Color(0xFF6B6781);
  static const Color textDisabled  = Color(0xFFA8A4B5);

  // ===== Статусы =====
  static const Color success       = Color(0xFF10B981);
  static const Color error         = Color(0xFFEF4444);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color info          = Color(0xFF3B82F6);

  // ===== Таймер =====
  static const Color timerGreen  = Color(0xFF10B981);
  static const Color timerYellow = Color(0xFFF59E0B);
  static const Color timerOrange = Color(0xFFF59E0B);
  static const Color timerRed    = Color(0xFFEF4444);
  static const Color timerDeep   = Color(0xFFEF4444);

  // ===== Карта =====
  static const Color mapHeatLow    = Color(0x337C3AED);
  static const Color mapHeatMid    = Color(0x66EC4899);
  static const Color mapHeatHigh   = Color(0xAAEC4899);
  static const Color safeZone      = success;
  static const Color activeUser    = primary;
  static const Color inactiveUser  = textSecondary;

  static const Color femaleGlowStart = Color(0xFFFF5FA8);
  static const Color femaleGlowEnd   = secondary;
  static const Color maleGlowStart   = Color(0xFF7C4DFF);
  static const Color maleGlowEnd     = Color(0xFF448AFF);

  // ===== Пара / штамп =====
  static const Color coupleGold = Color(0xFFFFB800);
  static const Color couplePink = secondary;
  static const Color stampInk   = Color(0xFF0F0A1F);

  // ===== Градиенты (обновлены под новый бренд) =====
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF5B21B6), Color(0xFF7C3AED), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF05030A), Color(0xFF120A24), Color(0xFF1E0F3D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient burnGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFEF4444)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Старый glassGradient — для совместимости с существующими экранами.
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

  /// Современная карточка: superellipse-скругление + тонкая обводка + soft shadow.
  /// Используется как замена `LiquidGlassCard` для новых экранов.
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
}
