package com.gohavefun.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.gohavefun.app.data.ThemeViewModel
import com.gohavefun.app.ui.theme.AppColors

/**
 * Главная оболочка приложения с нижней навигацией.
 * Табы: Карта / Пара / Котики / Профиль. Перенесено из Flutter (MainShell).
 */
@Composable
fun MainShell(rootNav: NavController, themeVm: ThemeViewModel) {
    var currentIndex by remember { mutableStateOf(0) }

    Box(modifier = Modifier.fillMaxSize().background(AppColors.Background)) {
        // Контент выбранного таба
        Box(modifier = Modifier.fillMaxSize().padding(bottom = 74.dp)) {
            when (currentIndex) {
                0 -> MapScreen(rootNav)
                1 -> CoupleScreen(onOpenMap = { currentIndex = 0 })
                2 -> CatsScreen()
                3 -> ProfileScreen(rootNav, themeVm)
            }
        }

        // Нижняя навигация
        BottomBar(
            currentIndex = currentIndex,
            onSelect = { currentIndex = it },
            modifier = Modifier.align(Alignment.BottomCenter)
        )
    }
}

private data class NavItem(val emoji: String, val label: String)

@Composable
private fun BottomBar(currentIndex: Int, onSelect: (Int) -> Unit, modifier: Modifier = Modifier) {
    val items = listOf(
        NavItem("🗺️", "Карта"),
        NavItem("💞", "Пара"),
        NavItem("🐱", "Котики"),
        NavItem("👤", "Профиль"),
    )
    Row(
        modifier = modifier
            .fillMaxWidth()
            .background(AppColors.Surface)
            .navigationBarsPadding()
            .height(74.dp)
            .padding(horizontal = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        items.forEachIndexed { i, item ->
            val selected = i == currentIndex
            Column(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(14.dp))
                    .clickable { onSelect(i) }
                    .padding(vertical = 8.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(12.dp))
                        .background(if (selected) AppColors.SurfaceAlt else Color.Transparent)
                        .padding(horizontal = 14.dp, vertical = 4.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(item.emoji, fontSize = 22.sp)
                }
                Spacer(Modifier.height(2.dp))
                Text(
                    item.label,
                    fontSize = 11.sp,
                    fontWeight = if (selected) FontWeight.W700 else FontWeight.W500,
                    color = if (selected) AppColors.Primary else AppColors.TextSecondary
                )
            }
        }
    }
}
