package com.gohavefun.app.ui.screens.main

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import kotlin.math.roundToInt
import com.gohavefun.app.data.AppConstants
import com.gohavefun.app.data.MapPhoto
import com.gohavefun.app.data.MapViewModel
import com.gohavefun.app.data.ThemeViewModel
import com.gohavefun.app.navigation.Routes
import com.gohavefun.app.ui.components.AppButton
import com.gohavefun.app.ui.components.AppCard
import com.gohavefun.app.ui.components.FeatureRow
import com.gohavefun.app.ui.components.IconBadge
import com.gohavefun.app.ui.components.ScreenContainer
import com.gohavefun.app.ui.components.SectionHeader
import com.gohavefun.app.ui.components.SettingRow
import com.gohavefun.app.ui.components.StatCard
import com.gohavefun.app.ui.screens.map.MapCanvas
import com.gohavefun.app.ui.screens.map.MapScreen
import com.gohavefun.app.ui.theme.AppColors

@Composable
fun MainShell(rootNav: NavController, themeVm: ThemeViewModel) {
    var currentIndex by remember { mutableStateOf(0) }

    Box(modifier = Modifier.fillMaxSize().background(AppColors.Background)) {
        Box(modifier = Modifier.fillMaxSize().padding(bottom = 74.dp)) {
            when (currentIndex) {
                0 -> MapScreen(rootNav)
                1 -> CoupleScreen(onOpenMap = { currentIndex = 0 })
                2 -> CatsScreen()
                3 -> ProfileScreen(rootNav, themeVm)
            }
        }

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

@Composable
fun CoupleScreen(onOpenMap: () -> Unit) {
    ScreenContainer(
        modifier = Modifier.verticalScroll(rememberScrollState()).padding(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(Modifier.height(40.dp))
        IconBadge("💞", modifier = Modifier.size(130.dp), backgroundColor = AppColors.Primary, contentSize = 68.sp)
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
        AppCard(
            modifier = Modifier.fillMaxWidth().height(54.dp).clickable { onOpenMap() },
            backgroundColor = AppColors.SurfaceVariant,
            cornerRadius = 18.dp,
            paddingValues = PaddingValues(0.dp)
        ) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text("Перейти к карте", color = AppColors.TextPrimary, fontWeight = FontWeight.W700)
            }
        }
        Spacer(Modifier.height(24.dp))
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CatsScreen() {
    val vm: MapViewModel = viewModel(key = "cats_map")
    val state by vm.state.collectAsState()
    var selectedPhoto by remember { mutableStateOf<MapPhoto?>(null) }

    Column(modifier = Modifier.fillMaxSize().background(AppColors.Background)) {
        Column(modifier = Modifier.statusBarsPadding().padding(20.dp)) {
            SectionHeader("Котики на карте 🐾", "Смотри фото котов рядом и добавляй своё")
            Spacer(Modifier.height(14.dp))
        }
        Box(modifier = Modifier.weight(1f).padding(horizontal = 16.dp)) {
            MapCanvas(
                state = state,
                modifier = Modifier.fillMaxSize(),
                showUsers = false,
                showPhotos = true,
                onPhotoTap = { selectedPhoto = it }
            )
        }
        Spacer(Modifier.height(12.dp))
        AppButton(
            label = "Сфотографировать кота",
            emoji = "📸",
            onClick = { vm.addCatPhoto("Фото моего кота рядом") }
        )
        Spacer(Modifier.height(20.dp))
    }

    if (selectedPhoto != null) {
        ModalBottomSheet(
            onDismissRequest = { selectedPhoto = null },
            sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
            containerColor = AppColors.Surface
        ) {
            Column(modifier = Modifier.fillMaxWidth().padding(20.dp)) {
                Text("Фото кота", color = AppColors.TextPrimary, fontSize = 20.sp, fontWeight = FontWeight.W800)
                Spacer(Modifier.height(14.dp))
                Image(
                    painter = painterResource(id = selectedPhoto!!.imageRes ?: com.gohavefun.app.R.drawable.cute_cat),
                    contentDescription = selectedPhoto!!.caption,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(220.dp)
                        .clip(RoundedCornerShape(18.dp))
                        .background(AppColors.SurfaceVariant),
                    contentScale = ContentScale.Crop
                )
                Spacer(Modifier.height(14.dp))
                Text(selectedPhoto!!.caption, color = AppColors.TextPrimary, fontSize = 16.sp)
                Spacer(Modifier.height(12.dp))
                Text("${selectedPhoto!!.ownerName}, около ${selectedPhoto!!.distanceMeters.roundToInt()} м", color = AppColors.TextSecondary, fontSize = 13.sp)
                Spacer(Modifier.height(20.dp))
                AppButton(label = "Закрыть", onClick = { selectedPhoto = null })
            }
        }
    }
}

@Composable
fun ProfileScreen(rootNav: NavController, themeVm: ThemeViewModel) {
    val isDark by themeVm.isDark.collectAsState()

    ScreenContainer(modifier = Modifier.verticalScroll(rememberScrollState())) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColors.HeroGradient)
                .statusBarsPadding()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            IconBadge("😎", modifier = Modifier.size(96.dp), backgroundColor = Color.White.copy(alpha = 0.2f), contentSize = 48.sp)
            Spacer(Modifier.height(12.dp))
            Text("Твой профиль", color = Color.White, fontSize = 22.sp, fontWeight = FontWeight.W800)
            Text("Онлайн • ищет знакомства", color = Color.White.copy(alpha = 0.85f), fontSize = 13.sp)
        }

        Column(modifier = Modifier.padding(20.dp)) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                StatCard("12", "Встреч", Modifier.weight(1f))
                StatCard("47", "Чатов", Modifier.weight(1f))
                StatCard("8", "Друзей", Modifier.weight(1f))
            }
            Spacer(Modifier.height(20.dp))

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
            AppCard(
                modifier = Modifier.fillMaxWidth().height(54.dp).clickable {
                    rootNav.navigate(Routes.LOGIN) {
                        popUpTo(Routes.MAP) { inclusive = true }
                    }
                },
                backgroundColor = AppColors.ErrorColor.copy(alpha = 0.12f),
                cornerRadius = 18.dp,
                paddingValues = PaddingValues(0.dp)
            ) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text("Выйти", color = AppColors.ErrorColor, fontWeight = FontWeight.W700)
                }
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
