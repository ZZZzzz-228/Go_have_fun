<<<<<<< Updated upstream
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
=======
package com.gohavefun.app.ui.screens

import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.gohavefun.app.data.ThemeViewModel
import com.gohavefun.app.ui.theme.AppColors

/**
 * Главная оболочка приложения с нижней навигацией.
 * Табы: Карта / Пара / Котики / Профиль. Перенесено из Flutter (MainShell).
 *
 * Нижняя навигация — плавающая "стеклянная стойка" (liquid glass tab bar):
 * полупрозрачная капсула, внутри которой бегает своя "жидкостекольная" таблетка
 * под выбранный таб, с пружинной анимацией — как в iOS.
 */
@Composable
fun MainShell(rootNav: NavController, themeVm: ThemeViewModel) {
    var currentIndex by remember { mutableStateOf(0) }

    Box(modifier = Modifier.fillMaxSize().background(AppColors.Background)) {
        // Контент выбранного таба. Снизу оставляем место под плавающий таббар
        // (высота стойки + отступы + запас), чтобы контент и кнопки на экранах
        // никогда не оказывались под стеклом.
        Box(modifier = Modifier.fillMaxSize().padding(bottom = BOTTOM_BAR_RESERVED_SPACE)) {
            when (currentIndex) {
                0 -> MapScreen(rootNav)
                1 -> CoupleScreen(onOpenMap = { currentIndex = 0 })
                2 -> CatsScreen()
                3 -> ProfileScreen(rootNav, themeVm)
            }
        }

        // Нижняя навигация — стеклянная плавающая стойка
        GlassBottomBar(
            currentIndex = currentIndex,
            onSelect = { currentIndex = it },
            modifier = Modifier.align(Alignment.BottomCenter)
        )
    }
}

// Общий отступ, который должны резервировать экраны-табы снизу под плавающий таббар.
// Используется и здесь, и на экранах (например MapScreen), чтобы поднимать над баром
// свои плавающие кнопки/CTA.
val BOTTOM_BAR_RESERVED_SPACE = 118.dp

private data class NavItem(val emoji: String, val label: String)

@Composable
private fun GlassBottomBar(currentIndex: Int, onSelect: (Int) -> Unit, modifier: Modifier = Modifier) {
    val items = listOf(
        NavItem("🗺️", "Карта"),
        NavItem("💞", "Пара"),
        NavItem("🐱", "Котики"),
        NavItem("👤", "Профиль"),
    )
    val itemCount = items.size

    BoxWithConstraints(
        modifier = modifier
            .fillMaxWidth()
            .navigationBarsPadding()
            .padding(horizontal = 20.dp)
            .padding(bottom = 16.dp)
    ) {
        val barHeight = 68.dp
        val itemWidth = maxWidth / itemCount

        // Плавная "жидкая" пружина — таблетка перетекает между табами,
        // чуть пружиня в конце, как liquid glass на iOS.
        val indicatorOffset by animateDpAsState(
            targetValue = itemWidth * currentIndex,
            animationSpec = spring(
                dampingRatio = Spring.DampingRatioMediumBouncy,
                stiffness = Spring.StiffnessLow
            ),
            label = "tabIndicatorOffset"
        )

        // Внешняя "стеклянная" капсула стойки
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(barHeight)
                .shadow(
                    elevation = 24.dp,
                    shape = RoundedCornerShape(34.dp),
                    ambientColor = AppColors.Primary.copy(alpha = 0.25f),
                    spotColor = AppColors.Primary.copy(alpha = 0.35f)
                )
                .clip(RoundedCornerShape(34.dp))
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            Color.White.copy(alpha = 0.62f),
                            Color.White.copy(alpha = 0.30f)
                        )
                    )
                )
                .blur(radius = 0.6.dp)
                .border(
                    width = 1.dp,
                    brush = Brush.verticalGradient(
                        colors = listOf(
                            Color.White.copy(alpha = 0.85f),
                            Color.White.copy(alpha = 0.15f)
                        )
                    ),
                    shape = RoundedCornerShape(34.dp)
                )
        ) {
            // "Жидкостекольная" таблетка под активным табом — едет по стойке
            Box(
                modifier = Modifier
                    .offset(x = indicatorOffset)
                    .padding(6.dp)
                    .width(itemWidth - 12.dp)
                    .fillMaxHeight()
                    .shadow(
                        elevation = 10.dp,
                        shape = RoundedCornerShape(26.dp),
                        ambientColor = Color.White.copy(alpha = 0.9f),
                        spotColor = AppColors.Primary.copy(alpha = 0.30f)
                    )
                    .clip(RoundedCornerShape(26.dp))
                    .background(
                        Brush.verticalGradient(
                            colors = listOf(
                                Color.White.copy(alpha = 0.95f),
                                Color.White.copy(alpha = 0.70f)
                            )
                        )
                    )
                    .border(
                        width = 1.dp,
                        color = Color.White.copy(alpha = 0.9f),
                        shape = RoundedCornerShape(26.dp)
                    )
            ) {
                // блик сверху для эффекта выпуклого стекла
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(barHeight / 2)
                        .padding(top = 3.dp, start = 6.dp, end = 6.dp)
                        .clip(RoundedCornerShape(topStart = 22.dp, topEnd = 22.dp))
                        .background(
                            Brush.verticalGradient(
                                colors = listOf(
                                    Color.White.copy(alpha = 0.55f),
                                    Color.White.copy(alpha = 0f)
                                )
                            )
                        )
                )
            }

            // Кнопки табов поверх стекла
            Row(
                modifier = Modifier.fillMaxSize(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                items.forEachIndexed { i, item ->
                    val selected = i == currentIndex
                    val scale by animateFloatAsState(
                        targetValue = if (selected) 1.12f else 1f,
                        animationSpec = spring(
                            dampingRatio = Spring.DampingRatioMediumBouncy,
                            stiffness = Spring.StiffnessLow
                        ),
                        label = "tabIconScale"
                    )
                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxHeight()
                            .clip(RoundedCornerShape(26.dp))
                            .clickable(
                                interactionSource = remember { MutableInteractionSource() },
                                indication = null
                            ) { onSelect(i) },
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = androidx.compose.foundation.layout.Arrangement.Center
                    ) {
                        Text(
                            item.emoji,
                            fontSize = 21.sp,
                            modifier = Modifier.graphicsLayer {
                                scaleX = scale
                                scaleY = scale
                            }
                        )
                        Spacer(Modifier.height(2.dp))
                        Text(
                            item.label,
                            fontSize = 10.sp,
                            fontWeight = if (selected) FontWeight.W700 else FontWeight.W500,
                            color = if (selected) AppColors.Primary else AppColors.TextSecondary
                        )
                    }
                }
            }
        }
    }
}
>>>>>>> Stashed changes
