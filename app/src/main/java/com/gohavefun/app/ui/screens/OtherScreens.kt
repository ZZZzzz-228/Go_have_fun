package com.gohavefun.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.gohavefun.app.data.AppConstants
import com.gohavefun.app.data.ThemeViewModel
import com.gohavefun.app.navigation.Routes
import com.gohavefun.app.ui.components.AppButton
import com.gohavefun.app.ui.theme.AppColors

/**
 * Экран "Пара" — режим совместного поиска для пар/друзей.
 * Перенесено из Flutter (CoupleScreen), упрощённая заглушка-презентация.
 */
@Composable
fun CoupleScreen(onOpenMap: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.Background)
            .verticalScroll(rememberScrollState())
            .padding(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(Modifier.height(40.dp))
        Box(
            modifier = Modifier
                .size(130.dp)
                .clip(CircleShape)
                .background(AppColors.MatchGradient),
            contentAlignment = Alignment.Center
        ) { Text("💞", fontSize = 68.sp) }
        Spacer(Modifier.height(24.dp))
        Text("Режим «Пара»", color = AppColors.TextPrimary, fontSize = 26.sp, fontWeight = FontWeight.W800)
        Spacer(Modifier.height(8.dp))
        Text(
            "Ищите новых друзей вдвоём! Пригласи вторую половинку или друга — и знакомьтесь с другими парами рядом.",
            color = AppColors.TextSecondary,
            fontSize = 15.sp,
            textAlign = TextAlign.Center
        )
        Spacer(Modifier.height(28.dp))

        FeatureRow("👫", "Двойные знакомства", "Встречайтесь пара на пару")
        FeatureRow("🎯", "Общие интересы", "Подбор по совпадениям")
        FeatureRow("🛡️", "Безопасно", "Всегда рядом свой человек")

        Spacer(Modifier.height(28.dp))
        AppButton(label = "Пригласить партнёра", emoji = "➕", onClick = onOpenMap)
        Spacer(Modifier.height(12.dp))
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp)
                .clip(RoundedCornerShape(18.dp))
                .background(AppColors.SurfaceVariant)
                .clickable { onOpenMap() },
            contentAlignment = Alignment.Center
        ) {
            Text("Перейти к карте", color = AppColors.TextPrimary, fontWeight = FontWeight.W700)
        }
        Spacer(Modifier.height(24.dp))
    }
}

@Composable
private fun FeatureRow(emoji: String, title: String, subtitle: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 6.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(AppColors.Surface)
            .padding(14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(48.dp)
                .clip(CircleShape)
                .background(AppColors.SurfaceAlt),
            contentAlignment = Alignment.Center
        ) { Text(emoji, fontSize = 24.sp) }
        Spacer(Modifier.width(14.dp))
        Column {
            Text(title, color = AppColors.TextPrimary, fontSize = 15.sp, fontWeight = FontWeight.W700)
            Text(subtitle, color = AppColors.TextSecondary, fontSize = 13.sp)
        }
    }
}

/**
 * Экран "Котики" — лента с забавным контентом (заглушка).
 * Перенесено из Flutter (CatsScreen).
 */
@Composable
fun CatsScreen() {
    val cats = listOf(
        Triple("🐱", "Барсик", "Ищет хозяина для игр"),
        Triple("🐈", "Мурка", "Обожает солнечные подоконники"),
        Triple("😺", "Рыжик", "Мастер сбивать вещи со стола"),
        Triple("🐈‍⬛", "Уголёк", "Ночной охотник за лазером"),
        Triple("😻", "Ласка", "Мурчит громче холодильника"),
    )
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.Background)
            .verticalScroll(rememberScrollState())
    ) {
        Column(modifier = Modifier.statusBarsPadding().padding(20.dp)) {
            Text("Котики дня 🐾", color = AppColors.TextPrimary, fontSize = 26.sp, fontWeight = FontWeight.W800)
            Spacer(Modifier.height(4.dp))
            Text("Немного тепла, пока ищешь встречу", color = AppColors.TextSecondary, fontSize = 14.sp)
            Spacer(Modifier.height(16.dp))
            cats.forEach { (emoji, name, desc) ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 6.dp)
                        .clip(RoundedCornerShape(18.dp))
                        .background(AppColors.Surface)
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(64.dp)
                            .clip(CircleShape)
                            .background(AppColors.SurfaceAlt),
                        contentAlignment = Alignment.Center
                    ) { Text(emoji, fontSize = 36.sp) }
                    Spacer(Modifier.width(16.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text(name, color = AppColors.TextPrimary, fontSize = 17.sp, fontWeight = FontWeight.W700)
                        Text(desc, color = AppColors.TextSecondary, fontSize = 13.sp)
                    }
                    Text("❤️", fontSize = 22.sp)
                }
            }
            Spacer(Modifier.height(24.dp))
        }
    }
}

/**
 * Экран профиля с переключателем темы и выходом.
 * Перенесено из Flutter (ProfileScreen).
 */
@Composable
fun ProfileScreen(rootNav: NavController, themeVm: ThemeViewModel) {
    val isDark by themeVm.isDark.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.Background)
            .verticalScroll(rememberScrollState())
    ) {
        // Шапка
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColors.HeroGradient)
                .statusBarsPadding()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .size(96.dp)
                    .clip(CircleShape)
                    .background(Color.White.copy(alpha = 0.2f)),
                contentAlignment = Alignment.Center
            ) { Text("😎", fontSize = 48.sp) }
            Spacer(Modifier.height(12.dp))
            Text("Твой профиль", color = Color.White, fontSize = 22.sp, fontWeight = FontWeight.W800)
            Text("Онлайн • ищет знакомства", color = Color.White.copy(alpha = 0.85f), fontSize = 13.sp)
        }

        Column(modifier = Modifier.padding(20.dp)) {
            // Статистика
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                StatCard("12", "Встреч", Modifier.weight(1f))
                StatCard("47", "Чатов", Modifier.weight(1f))
                StatCard("8", "Друзей", Modifier.weight(1f))
            }
            Spacer(Modifier.height(20.dp))

            // Тёмная тема
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(16.dp))
                    .background(AppColors.Surface)
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("🌙", fontSize = 22.sp)
                Spacer(Modifier.width(12.dp))
                Text("Тёмная тема", color = AppColors.TextPrimary, fontSize = 15.sp, fontWeight = FontWeight.W600, modifier = Modifier.weight(1f))
                Switch(
                    checked = isDark,
                    onCheckedChange = { themeVm.toggle() },
                    colors = SwitchDefaults.colors(checkedTrackColor = AppColors.Primary)
                )
            }
            Spacer(Modifier.height(12.dp))

            SettingRow("✏️", "Редактировать профиль")
            SettingRow("🔔", "Уведомления")
            SettingRow("🛡️", "Приватность и безопасность")
            SettingRow("❓", "Помощь")

            Spacer(Modifier.height(20.dp))
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(54.dp)
                    .clip(RoundedCornerShape(18.dp))
                    .background(AppColors.ErrorColor.copy(alpha = 0.12f))
                    .clickable {
                        rootNav.navigate(Routes.LOGIN) {
                            popUpTo(Routes.MAP) { inclusive = true }
                        }
                    },
                contentAlignment = Alignment.Center
            ) {
                Text("Выйти", color = AppColors.ErrorColor, fontWeight = FontWeight.W700)
            }
            Spacer(Modifier.height(16.dp))
            Text(
                "${AppConstants.APP_NAME} v${AppConstants.APP_VERSION}",
                color = AppColors.TextDisabled,
                fontSize = 12.sp,
                modifier = Modifier.fillMaxWidth(),
                textAlign = TextAlign.Center
            )
            Spacer(Modifier.height(24.dp))
        }
    }
}

@Composable
private fun StatCard(value: String, label: String, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(16.dp))
            .background(AppColors.Surface)
            .padding(vertical = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(value, color = AppColors.Primary, fontSize = 22.sp, fontWeight = FontWeight.W800)
        Text(label, color = AppColors.TextSecondary, fontSize = 12.sp)
    }
}

@Composable
private fun SettingRow(emoji: String, title: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 5.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(AppColors.Surface)
            .clickable { }
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(emoji, fontSize = 20.sp)
        Spacer(Modifier.width(14.dp))
        Text(title, color = AppColors.TextPrimary, fontSize = 15.sp, fontWeight = FontWeight.W600, modifier = Modifier.weight(1f))
        Text("›", color = AppColors.TextSecondary, fontSize = 22.sp)
    }
}
