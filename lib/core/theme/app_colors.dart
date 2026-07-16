import 'package:flutter/material.dart';

/// Чёрно-фиолетовая неоновая палитра Go Have Fun.
/// Тёмный космос + фиолетово-розовое неоновое сияние — вместо прежней
/// коралловой/оранжевой темы.
class AppColors {
  AppColors._();

  // ===== Основные цвета бренда =====
  static const Color primary = Color(0xFF9B5CFF); // Неоновый фиолетовый
  static const Color secondary = Color(0xFFD946EF); // Пурпурно-розовый
  static const Color tertiary = Color(0xFF6D28D9); // Глубокий фиолетовый

  // ===== Фоны =====
  static const Color background = Color(0xFF07040F); // Почти чёрный космос
  static const Color surface = Color(0xFF140A26); // Тёмно-фиолетовая поверхность
  static const Color surfaceVariant = Color(0xFF1F1238); // Средний фиолетовый

  // ===== "Стеклянные" оттенки для Liquid Glass =====
  static const Color glassLight = Color(0x1FFFFFFF); // белая подсветка стекла
  static const Color glassBorder = Color(0x33C9A8FF); // фиолетовая кайма стекла
  static const Color glassDark = Color(0xCC0A0514); // тёмная подложка стекла

  // ===== Текст =====
  static const Color textPrimary = Color(0xFFF5F0FF);
  static const Color textSecondary = Color(0xFFAB9BC7);
  static const Color textDisabled = Color(0xFF544B6B);

  // ===== Статусы =====
  static const Color success = Color(0xFF4CD97B);
  static const Color error = Color(0xFFFF6584);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF64B5F6);

  // ===== Таймер (горение чата) =====
  static const Color timerGreen = Color(0xFF4CD97B);
  static const Color timerYellow = Color(0xFFFFC107);
  static const Color timerOrange = Color(0xFFFF9800);
  static const Color timerRed = Color(0xFFFF6584);
  static const Color timerDeep = Color(0xFFD32F2F);

  // ===== Карта =====
  static const Color mapHeatLow = Color(0x339B5CFF);
  static const Color mapHeatMid = Color(0x66D946EF);
  static const Color mapHeatHigh = Color(0xAAD946EF);
  static const Color safeZone = Color(0xFF4CD97B);
  static const Color activeUser = Color(0xFF9B5CFF);
  static const Color inactiveUser = Color(0xFFAB9BC7);

  // Неоновое сияние маркеров пользователей на карте по гендеру
  static const Color femaleGlowStart = Color(0xFFFF5FA8);
  static const Color femaleGlowEnd = Color(0xFFD946EF);
  static const Color maleGlowStart = Color(0xFF7C4DFF);
  static const Color maleGlowEnd = Color(0xFF448AFF);

  // ===== Пара / штамп =====
  static const Color coupleGold = Color(0xFFFFD700);
  static const Color couplePink = Color(0xFFD946EF);
  static const Color stampInk = Color(0xFF140A26);

  // ===== Градиенты =====
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF9B5CFF), Color(0xFFD946EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF3A0CA3), Color(0xFF9B5CFF), Color(0xFFD946EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [
      Color(0xFF05030A),
      Color(0xFF120A24),
      Color(0xFF1E0F3D),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient burnGradient = LinearGradient(
    colors: [Color(0xFFFF6584), Color(0xFFD32F2F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Полупрозрачный фиолетовый градиент для "стеклянных" карточек.
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
}
