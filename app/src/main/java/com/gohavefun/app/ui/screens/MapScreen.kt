package com.gohavefun.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.gohavefun.app.data.AppConstants
import com.gohavefun.app.data.MapUser
import com.gohavefun.app.data.MapViewModel
import com.gohavefun.app.navigation.Routes
import com.gohavefun.app.ui.components.AppButton
import com.gohavefun.app.ui.components.MapFab
import com.gohavefun.app.ui.theme.AppColors
import androidx.compose.foundation.Canvas
import kotlin.math.roundToInt

/**
 * Экран карты. Настоящая карта заменена схематичной (сетка + точки пользователей),
 * чтобы работать без внешних API-ключей. Перенесено из Flutter (MapScreen).
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapScreen(rootNav: NavController) {
    val vm: MapViewModel = viewModel()
    val state by vm.state.collectAsState()

    var showBeaconSheet by remember { mutableStateOf(false) }
    var selectedUser by remember { mutableStateOf<MapUser?>(null) }
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    Box(modifier = Modifier.fillMaxSize().background(AppColors.SurfaceVariant)) {

        // ==== Схематичная карта ====
        SchematicMap(
            state = state,
            onUserTap = { selectedUser = it },
            modifier = Modifier.fillMaxSize()
        )

        // ==== Верхняя панель ====
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .statusBarsPadding()
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(16.dp))
                    .background(AppColors.Surface)
                    .padding(14.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("📍", fontSize = 20.sp)
                Spacer(Modifier.width(8.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        state.streetName,
                        color = AppColors.TextPrimary,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.W700
                    )
                    Text(
                        if (state.isSearchActive) "Поиск активен • ${formatTime(state.searchSecondsRemaining)}"
                        else "Поиск выключен",
                        color = if (state.isSearchActive) AppColors.Success else AppColors.TextSecondary,
                        fontSize = 12.sp
                    )
                }
                Text("${state.weatherEmoji} ${state.temperatureC ?: "--"}°", fontSize = 15.sp)
            }

            if (state.isPanicMode) {
                Spacer(Modifier.height(10.dp))
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(14.dp))
                        .background(AppColors.ErrorColor)
                        .padding(12.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        "🛡️ Режим паники активен — ты невидим(а) 30 сек",
                        color = Color.White,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.W700
                    )
                }
            }
        }

        // ==== Правые плавающие кнопки ====
        Column(
            modifier = Modifier
                .align(Alignment.CenterEnd)
                .padding(end = 16.dp),
            horizontalAlignment = Alignment.End,
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Маячок
            MapFab(onClick = { showBeaconSheet = true }, bg = AppColors.Surface) {
                Text(state.currentBeaconEmoji ?: "📢", fontSize = 22.sp)
            }
            // Паника
            MapFab(onClick = { vm.activatePanic() }, bg = AppColors.ErrorColor) {
                Text("🛡️", fontSize = 22.sp)
            }
        }

        // ==== Нижняя кнопка старт/стоп поиска ====
        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            AppButton(
                label = if (state.isSearchActive) "Остановить поиск" else "Начать поиск людей",
                emoji = if (state.isSearchActive) "⏹️" else "🔍",
                onClick = {
                    if (state.isSearchActive) vm.stopSearchSession()
                    else vm.startSearchSession()
                }
            )
        }
    }

    // ==== Шит: выбор маячка ====
    if (showBeaconSheet) {
        ModalBottomSheet(
            onDismissRequest = { showBeaconSheet = false },
            sheetState = sheetState,
            containerColor = AppColors.Surface
        ) {
            BeaconSheet(
                current = state.currentBeaconText,
                onSelect = { emoji, text ->
                    vm.setBeacon(emoji, text)
                    showBeaconSheet = false
                }
            )
        }
    }

    // ==== Шит: профиль пользователя ====
    selectedUser?.let { user ->
        ModalBottomSheet(
            onDismissRequest = { selectedUser = null },
            sheetState = sheetState,
            containerColor = AppColors.Surface
        ) {
            UserProfileSheet(
                user = user,
                onSkip = {
                    vm.skipMatch(user.userId)
                    selectedUser = null
                },
                onChat = {
                    selectedUser = null
                    rootNav.navigate("${Routes.CHAT}/${user.userId}")
                }
            )
        }
    }
}

/** Схематичная карта на Canvas: фон-сетка, безопасные зоны и точки-пользователи. */
@Composable
private fun SchematicMap(
    state: com.gohavefun.app.data.MapState,
    onUserTap: (MapUser) -> Unit,
    modifier: Modifier = Modifier
) {
    var boxW by remember { mutableStateOf(0) }
    var boxH by remember { mutableStateOf(0) }

    Box(modifier = modifier.onSizeChanged { boxW = it.width; boxH = it.height }) {
        // Сетка
        Canvas(modifier = Modifier.fillMaxSize()) {
            val step = 48.dp.toPx()
            val lineColor = AppColors.Border.copy(alpha = 0.6f)
            var x = 0f
            while (x < size.width) {
                drawLine(lineColor, Offset(x, 0f), Offset(x, size.height), strokeWidth = 1f)
                x += step
            }
            var y = 0f
            while (y < size.height) {
                drawLine(lineColor, Offset(0f, y), Offset(size.width, y), strokeWidth = 1f)
                y += step
            }
            // "я" в центре — пульсирующий круг
            val center = Offset(size.width / 2f, size.height / 2f)
            drawCircle(AppColors.Primary.copy(alpha = 0.12f), radius = 90f, center = center)
            drawCircle(AppColors.Primary.copy(alpha = 0.20f), radius = 55f, center = center, style = Stroke(width = 3f))
        }

        // "Я" по центру
        Box(
            modifier = Modifier.align(Alignment.Center),
            contentAlignment = Alignment.Center
        ) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(AppColors.PrimaryGradient),
                contentAlignment = Alignment.Center
            ) { Text("😎", fontSize = 20.sp) }
        }

        // Безопасные зоны
        if (boxW > 0 && boxH > 0) {
            state.safeZones.forEach { zone ->
                val px = (zone.relX * boxW).roundToInt()
                val py = (zone.relY * boxH).roundToInt()
                Column(
                    modifier = Modifier.offset { IntOffset(px - 24, py - 24) },
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .clip(CircleShape)
                            .background(AppColors.SafeZone.copy(alpha = 0.18f))
                            .border(1.5.dp, AppColors.SafeZone, CircleShape),
                        contentAlignment = Alignment.Center
                    ) { Text(zone.emoji, fontSize = 18.sp) }
                }
            }

            // Пользователи
            state.nearbyUsers.forEach { user ->
                val px = (user.relX * boxW).roundToInt()
                val py = (user.relY * boxH).roundToInt()
                Column(
                    modifier = Modifier
                        .offset { IntOffset(px - 26, py - 34) }
                        .clickable { onUserTap(user) },
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(
                        modifier = Modifier
                            .size(52.dp)
                            .clip(CircleShape)
                            .background(if (user.isFemale) AppColors.Secondary else AppColors.Primary),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(user.beaconEmoji ?: "🙂", fontSize = 24.sp)
                    }
                    Box(
                        modifier = Modifier
                            .padding(top = 2.dp)
                            .clip(RoundedCornerShape(8.dp))
                            .background(AppColors.Surface)
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    ) {
                        Text(
                            "${user.name}, ${user.age}",
                            fontSize = 10.sp,
                            fontWeight = FontWeight.W600,
                            color = AppColors.TextPrimary
                        )
                    }
                }
            }
        }
    }
}

/** Содержимое шита выбора маячка. */
@Composable
fun BeaconSheet(current: String?, onSelect: (String, String) -> Unit) {
    Column(modifier = Modifier.fillMaxWidth().padding(20.dp)) {
        Text("Выбери маячок", color = AppColors.TextPrimary, fontSize = 20.sp, fontWeight = FontWeight.W800)
        Spacer(Modifier.height(4.dp))
        Text("Люди рядом увидят твой статус", color = AppColors.TextSecondary, fontSize = 13.sp)
        Spacer(Modifier.height(16.dp))
        LazyColumn {
            items(AppConstants.beaconStatuses) { (emoji, text) ->
                val selected = current == text
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 5.dp)
                        .clip(RoundedCornerShape(14.dp))
                        .background(if (selected) AppColors.SurfaceAlt else AppColors.SurfaceVariant)
                        .clickable { onSelect(emoji, text) }
                        .padding(14.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(emoji, fontSize = 24.sp)
                    Spacer(Modifier.width(12.dp))
                    Text(
                        text,
                        color = AppColors.TextPrimary,
                        fontSize = 15.sp,
                        fontWeight = if (selected) FontWeight.W700 else FontWeight.W500
                    )
                }
            }
        }
        Spacer(Modifier.height(16.dp))
    }
}

/** Содержимое шита профиля пользователя. */
@Composable
fun UserProfileSheet(user: MapUser, onSkip: () -> Unit, onChat: () -> Unit) {
    Column(
        modifier = Modifier.fillMaxWidth().padding(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier
                .size(84.dp)
                .clip(CircleShape)
                .background(if (user.isFemale) AppColors.Secondary else AppColors.Primary),
            contentAlignment = Alignment.Center
        ) { Text(user.beaconEmoji ?: "🙂", fontSize = 40.sp) }
        Spacer(Modifier.height(12.dp))
        Text("${user.name}, ${user.age}", color = AppColors.TextPrimary, fontSize = 22.sp, fontWeight = FontWeight.W800)
        Spacer(Modifier.height(4.dp))
        Text(user.beaconDisplay, color = AppColors.TextSecondary, fontSize = 14.sp)
        Spacer(Modifier.height(4.dp))
        Text(
            "📍 ${user.distanceMeters.roundToInt()} м от тебя" +
                (user.batteryLevel?.let { " • 🔋 $it%" } ?: ""),
            color = AppColors.TextSecondary,
            fontSize = 13.sp
        )
        Spacer(Modifier.height(24.dp))
        Row(modifier = Modifier.fillMaxWidth()) {
            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(54.dp)
                    .clip(RoundedCornerShape(18.dp))
                    .background(AppColors.SurfaceVariant)
                    .clickable { onSkip() },
                contentAlignment = Alignment.Center
            ) {
                Text("Пропустить", color = AppColors.TextSecondary, fontWeight = FontWeight.W700)
            }
            Spacer(Modifier.width(12.dp))
            Box(modifier = Modifier.weight(1f)) {
                AppButton(label = "Чат", emoji = "💬", onClick = onChat)
            }
        }
        Spacer(Modifier.height(16.dp))
    }
}

fun formatTime(totalSeconds: Int): String {
    val h = totalSeconds / 3600
    val m = (totalSeconds % 3600) / 60
    val s = totalSeconds % 60
    return if (h > 0) "%d:%02d:%02d".format(h, m, s) else "%02d:%02d".format(m, s)
}
