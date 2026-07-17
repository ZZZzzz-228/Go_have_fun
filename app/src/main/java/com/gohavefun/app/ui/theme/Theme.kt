package com.gohavefun.app.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

private val LightColors = lightColorScheme(
    primary = AppColors.Primary,
    onPrimary = Color.White,
    secondary = AppColors.Secondary,
    tertiary = AppColors.Match,
    background = AppColors.Background,
    onBackground = AppColors.TextPrimary,
    surface = AppColors.Surface,
    onSurface = AppColors.TextPrimary,
    surfaceVariant = AppColors.SurfaceVariant,
    error = AppColors.ErrorColor,
    outline = AppColors.Border,
)

private val DarkColors = darkColorScheme(
    primary = AppColors.Primary,
    onPrimary = Color.White,
    secondary = AppColors.Secondary,
    tertiary = AppColors.Match,
    background = AppColors.DarkBackground,
    onBackground = AppColors.TextPrimaryDark,
    surface = AppColors.DarkSurface,
    onSurface = AppColors.TextPrimaryDark,
    surfaceVariant = AppColors.DarkSurfaceAlt,
    error = AppColors.ErrorColor,
    outline = AppColors.BorderDark,
)

private val AppTypography = Typography(
    displayLarge = TextStyle(fontSize = 40.sp, fontWeight = FontWeight.W900),
    displayMedium = TextStyle(fontSize = 32.sp, fontWeight = FontWeight.W800),
    displaySmall = TextStyle(fontSize = 26.sp, fontWeight = FontWeight.W800),
    headlineLarge = TextStyle(fontSize = 28.sp, fontWeight = FontWeight.W800),
    headlineMedium = TextStyle(fontSize = 24.sp, fontWeight = FontWeight.W700),
    headlineSmall = TextStyle(fontSize = 20.sp, fontWeight = FontWeight.W700),
    titleLarge = TextStyle(fontSize = 19.sp, fontWeight = FontWeight.W700),
    titleMedium = TextStyle(fontSize = 16.sp, fontWeight = FontWeight.W600),
    bodyLarge = TextStyle(fontSize = 16.sp, fontWeight = FontWeight.W400),
    bodyMedium = TextStyle(fontSize = 14.sp, fontWeight = FontWeight.W400),
    bodySmall = TextStyle(fontSize = 12.sp, fontWeight = FontWeight.W400),
    labelLarge = TextStyle(fontSize = 15.sp, fontWeight = FontWeight.W600),
    labelMedium = TextStyle(fontSize = 13.sp, fontWeight = FontWeight.W600),
    labelSmall = TextStyle(fontSize = 11.sp, fontWeight = FontWeight.W600),
)

@Composable
fun GoHaveFunTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = if (darkTheme) DarkColors else LightColors,
        typography = AppTypography,
        content = content
    )
}
