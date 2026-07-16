import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Основные цвета бренда
  static const Color primary = Color(0xFFFF4E6A);    // Яркий коралловый/розовый
  static const Color secondary = Color(0xFFFF8E53);  // Оранжевый акцент
  static const Color tertiary = Color(0xFF7C4DFF);   // Фиолетовый

  // Фоны
  static const Color background = Color(0xFF0F0F14); // Почти чёрный
  static const Color surface = Color(0xFF1A1A24);    // Тёмный серый
  static const Color surfaceVariant = Color(0xFF242434); // Средний тёмный

  // Текст
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9B9BB0);
  static const Color textDisabled = Color(0xFF55556A);

  // Статусы
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF4E6A);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Таймер (горение чата)
  static const Color timerGreen = Color(0xFF4CAF50);
  static const Color timerYellow = Color(0xFFFFC107);
  static const Color timerOrange = Color(0xFFFF9800);
  static const Color timerRed = Color(0xFFFF4E6A);
  static const Color timerDeep = Color(0xFFD32F2F);

  // Карта
  static const Color mapHeatLow = Color(0x33FF8E53);
  static const Color mapHeatMid = Color(0x66FF4E6A);
  static const Color mapHeatHigh = Color(0xAAFF4E6A);
  static const Color safeZone = Color(0xFF4CAF50);
  static const Color activeUser = Color(0xFFFF4E6A);
  static const Color inactiveUser = Color(0xFF9B9BB0);

  // Пара / штамп
  static const Color coupleGold = Color(0xFFFFD700);
  static const Color couplePink = Color(0xFFFF4E6A);
  static const Color stampInk = Color(0xFF1A1A24);

  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF4E6A), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F0F14), Color(0xFF1A1A24)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient burnGradient = LinearGradient(
    colors: [Color(0xFFFF4E6A), Color(0xFFD32F2F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
