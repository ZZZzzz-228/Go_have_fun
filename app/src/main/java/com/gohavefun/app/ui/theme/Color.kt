package com.gohavefun.app.ui.theme

import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color

/**
 * Яркая молодёжная палитра приложения "Go Have Fun".
 * Перенесено из Flutter (AppColors).
 */
object AppColors {
    // ===== Бренд / МЭТЧ =====
    val Primary = Color(0xFF6C5CE7)
    val PrimaryDark = Color(0xFF5A4BD1)
    val Secondary = Color(0xFFFF6B9D)
    val Match = Color(0xFFFF3366)
    val MatchGlow = Color(0xFFFF6B9D)
    val Accent = Color(0xFF00D9A5)
    val AccentAlt = Color(0xFFFFBE0B)

    // ===== Светлая тема =====
    val Background = Color(0xFFF5F3FF)
    val Surface = Color(0xFFFFFFFF)
    val SurfaceAlt = Color(0xFFEDE9FE)
    val SurfaceVariant = Color(0xFFF0ECFF)

    // ===== Тёмная тема =====
    val DarkBackground = Color(0xFF0D0B1A)
    val DarkSurface = Color(0xFF1A1730)
    val DarkSurfaceAlt = Color(0xFF252140)

    // ===== Обводки =====
    val Border = Color(0xFFE8E4F0)
    val BorderStrong = Color(0xFFD4CEE8)
    val BorderDark = Color(0xFF3D3658)

    // ===== Текст =====
    val TextPrimary = Color(0xFF1A1033)
    val TextSecondary = Color(0xFF6B6280)
    val TextDisabled = Color(0xFFA8A0B8)
    val TextPrimaryDark = Color(0xFFF5F0FF)
    val TextSecondaryDark = Color(0xFFB8B0CC)

    // ===== Статусы =====
    val Success = Color(0xFF00D9A5)
    val ErrorColor = Color(0xFFFF4757)
    val Warning = Color(0xFFFFBE0B)
    val Info = Color(0xFF54A0FF)

    // ===== Таймер =====
    val TimerGreen = Success
    val TimerYellow = Warning
    val TimerOrange = Color(0xFFFF8C42)
    val TimerRed = ErrorColor

    // ===== Карта =====
    val SafeZone = Accent
    val MapHeatMid = Color(0xFFFF6B9D)

    // ===== Пара =====
    val CoupleGold = Color(0xFFFFBE0B)
    val CouplePink = Secondary

    // ===== Градиенты =====
    val PrimaryGradient = Brush.linearGradient(
        colors = listOf(Color(0xFF6C5CE7), Color(0xFFFF6B9D))
    )

    val MatchGradient = Brush.linearGradient(
        colors = listOf(Color(0xFFFF3366), Color(0xFFFF6B9D), Color(0xFFFFBE0B))
    )

    val HeroGradient = Brush.linearGradient(
        colors = listOf(Color(0xFF5A4BD1), Color(0xFF6C5CE7), Color(0xFFFF6B9D))
    )
}
