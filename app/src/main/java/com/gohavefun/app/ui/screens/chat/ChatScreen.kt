package com.gohavefun.app.ui.screens.chat

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
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.gohavefun.app.data.AppConstants
import com.gohavefun.app.data.ChatMessage
import com.gohavefun.app.data.ChatViewModel
import com.gohavefun.app.navigation.Routes
import com.gohavefun.app.ui.components.AppButton
import com.gohavefun.app.ui.screens.map.formatTime
import com.gohavefun.app.ui.theme.AppColors

@Composable
fun ChatScreen(nav: NavController, chatId: String) {
    val vm: ChatViewModel = viewModel()
    val state by vm.state.collectAsState()

    LaunchedEffect(chatId) { vm.initChat(chatId) }

    LaunchedEffect(state.isExpired) {
        if (state.isExpired) {
            nav.navigate(Routes.CHAT_EXPIRED) {
                popUpTo("${Routes.CHAT}/{chatId}") { inclusive = true }
            }
        }
    }

    val listState = rememberLazyListState()
    LaunchedEffect(state.messages.size) {
        if (state.messages.isNotEmpty()) listState.animateScrollToItem(state.messages.size - 1)
    }

    var input by remember { mutableStateOf("") }

    val timerColor = when {
        state.secondsRemaining <= AppConstants.CRITICAL_ZONE_SECONDS -> AppColors.TimerRed
        state.secondsRemaining <= AppConstants.BURN_ZONE_SECONDS -> AppColors.TimerOrange
        state.secondsRemaining <= AppConstants.CHAT_DURATION_SECONDS / 2 -> AppColors.TimerYellow
        else -> AppColors.TimerGreen
    }
    val progress = state.secondsRemaining.toFloat() / state.totalSeconds.toFloat()

    Column(modifier = Modifier.fillMaxSize().background(AppColors.Background)) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColors.Surface)
                .statusBarsPadding()
                .padding(horizontal = 16.dp, vertical = 12.dp)
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    "←", fontSize = 24.sp, color = AppColors.TextPrimary,
                    modifier = Modifier.clickable { nav.popBackStack() }
                )
                Spacer(Modifier.width(12.dp))
                Box(
                    modifier = Modifier
                        .size(42.dp)
                        .clip(CircleShape)
                        .background(AppColors.Secondary),
                    contentAlignment = Alignment.Center
                ) { Text("🙂", fontSize = 20.sp) }
                Spacer(Modifier.width(10.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(state.partnerName, color = AppColors.TextPrimary, fontSize = 16.sp, fontWeight = FontWeight.W700)
                    Text("в сети", color = AppColors.Success, fontSize = 12.sp)
                }
                Text("🔥 " + formatTime(state.secondsRemaining), color = timerColor, fontSize = 18.sp, fontWeight = FontWeight.W800)
            }
            Spacer(Modifier.height(10.dp))
            LinearProgressIndicator(
                progress = { progress.coerceIn(0f, 1f) },
                color = timerColor,
                trackColor = AppColors.Border,
                modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(3.dp))
            )
        }

        state.icebreaker?.let { ice ->
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
                    .clip(RoundedCornerShape(16.dp))
                    .background(AppColors.SurfaceAlt)
                    .padding(14.dp)
            ) {
                Column {
                    Text("🧊 Ледокол", color = AppColors.Primary, fontSize = 12.sp, fontWeight = FontWeight.W700)
                    Spacer(Modifier.height(4.dp))
                    Text(ice, color = AppColors.TextPrimary, fontSize = 14.sp)
                }
            }
        }

        LazyColumn(
            state = listState,
            modifier = Modifier.weight(1f).fillMaxWidth().padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(state.messages.size) { i ->
                MessageBubble(state.messages[i])
            }
        }

        if (state.secondsRemaining <= AppConstants.BURN_ZONE_SECONDS && !state.isExpired) {
            Box(modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 4.dp)) {
                AppButton(
                    label = if (state.myWantsExtend) "Ждём партнёра..." else "Продлить чат (+5 мин)",
                    emoji = "⏰",
                    isLoading = state.myWantsExtend,
                    onClick = { vm.requestExtend() }
                )
            }
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColors.Surface)
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            OutlinedTextField(
                value = input,
                onValueChange = { input = it },
                placeholder = { Text("Сообщение...") },
                modifier = Modifier.weight(1f),
                singleLine = true
            )
            Spacer(Modifier.width(8.dp))
            Box(
                modifier = Modifier
                    .size(50.dp)
                    .clip(CircleShape)
                    .background(AppColors.PrimaryGradient)
                    .clickable {
                        if (input.isNotBlank()) {
                            vm.sendMessage(input.trim())
                            input = ""
                        }
                    },
                contentAlignment = Alignment.Center
            ) { Text("➤", color = Color.White, fontSize = 20.sp) }
        }
    }
}

@Composable
private fun MessageBubble(msg: ChatMessage) {
    val isMine = msg.senderId == "me"
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = if (isMine) Arrangement.End else Arrangement.Start
    ) {
        Box(
            modifier = Modifier
                .widthIn(max = 260.dp)
                .clip(
                    RoundedCornerShape(
                        topStart = 16.dp, topEnd = 16.dp,
                        bottomStart = if (isMine) 16.dp else 4.dp,
                        bottomEnd = if (isMine) 4.dp else 16.dp
                    )
                )
                .background(if (isMine) AppColors.Primary else AppColors.Surface)
                .padding(horizontal = 14.dp, vertical = 10.dp)
        ) {
            Text(
                msg.text,
                color = if (isMine) Color.White else AppColors.TextPrimary,
                fontSize = 15.sp
            )
        }
    }
}

@Composable
fun ChatExpiredScreen(nav: NavController) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.Background)
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Box(
            modifier = Modifier
                .size(120.dp)
                .clip(CircleShape)
                .background(AppColors.ErrorColor.copy(alpha = 0.12f)),
            contentAlignment = Alignment.Center
        ) { Text("🔥", fontSize = 64.sp) }
        Spacer(Modifier.height(24.dp))
        Text("Чат сгорел", color = AppColors.TextPrimary, fontSize = 26.sp, fontWeight = FontWeight.W800)
        Spacer(Modifier.height(8.dp))
        Text(
            "Время вышло. Успели договориться о встрече?\nЕсли да — увидимся вживую! 🎉",
            color = AppColors.TextSecondary,
            fontSize = 15.sp,
            textAlign = TextAlign.Center
        )
        Spacer(Modifier.height(36.dp))
        AppButton(
            label = "Вернуться на карту",
            emoji = "🗺️",
            onClick = {
                nav.navigate(Routes.MAP) {
                    popUpTo(Routes.MAP) { inclusive = true }
                }
            }
        )
    }
}
