package com.gohavefun.app.ui.screens

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.gohavefun.app.data.AppConstants
import com.gohavefun.app.navigation.Routes
import com.gohavefun.app.ui.components.AppButton
import com.gohavefun.app.ui.theme.AppColors
import kotlinx.coroutines.delay

/** Экран заставки. Через 2 секунды переходит на онбординг. */
@Composable
fun SplashScreen(nav: NavController) {
    val infinite = rememberInfiniteTransition(label = "splash")
    val scale by infinite.animateFloat(
        initialValue = 0.9f,
        targetValue = 1.1f,
        animationSpec = infiniteRepeatable(
            animation = tween(900, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "scale"
    )

    LaunchedEffect(Unit) {
        delay(2000)
        nav.navigate(Routes.ONBOARDING) {
            popUpTo(Routes.SPLASH) { inclusive = true }
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.HeroGradient),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Box(
                modifier = Modifier
                    .size(110.dp)
                    .scale(scale)
                    .clip(CircleShape)
                    .background(Color.White.copy(alpha = 0.15f)),
                contentAlignment = Alignment.Center
            ) {
                Text("✨", fontSize = 56.sp)
            }
            Spacer(Modifier.height(24.dp))
            Text(
                AppConstants.APP_NAME,
                color = Color.White,
                fontSize = 34.sp,
                fontWeight = FontWeight.W800
            )
            Spacer(Modifier.height(8.dp))
            Text(
                "Знакомься вживую. Прямо сейчас.",
                color = Color.White.copy(alpha = 0.85f),
                fontSize = 15.sp
            )
        }
    }
}

/** Онбординг — короткое описание сути приложения. */
@Composable
fun OnboardingScreen(nav: NavController) {
    val pages = listOf(
        Triple("📍", "Люди рядом", "Находи тех, кто хочет знакомиться прямо сейчас и рядом с тобой."),
        Triple("🔥", "Чат, который горит", "У вас всего 15 минут — не откладывай встречу на потом."),
        Triple("☕", "Безопасные места", "Встречайтесь в проверенных публичных местах — кофейни, бары, парки."),
    )
    var index by remember { mutableStateOf(0) }
    val page = pages[index]

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.Background)
            .padding(24.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Box(
                modifier = Modifier
                    .size(140.dp)
                    .clip(CircleShape)
                    .background(AppColors.SurfaceAlt),
                contentAlignment = Alignment.Center
            ) {
                Text(page.first, fontSize = 72.sp)
            }
            Spacer(Modifier.height(32.dp))
            Text(
                page.second,
                color = AppColors.TextPrimary,
                fontSize = 26.sp,
                fontWeight = FontWeight.W800,
                textAlign = TextAlign.Center
            )
            Spacer(Modifier.height(12.dp))
            Text(
                page.third,
                color = AppColors.TextSecondary,
                fontSize = 16.sp,
                textAlign = TextAlign.Center
            )
        }

        // Индикатор страниц
        Row(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 96.dp),
            horizontalArrangement = Arrangement.Center
        ) {
            pages.indices.forEach { i ->
                Box(
                    modifier = Modifier
                        .padding(horizontal = 4.dp)
                        .size(width = if (i == index) 22.dp else 8.dp, height = 8.dp)
                        .clip(RoundedCornerShape(4.dp))
                        .background(if (i == index) AppColors.Primary else AppColors.Border)
                )
            }
        }

        Column(modifier = Modifier.align(Alignment.BottomCenter)) {
            AppButton(
                label = if (index < pages.lastIndex) "Далее" else "Начать",
                onClick = {
                    if (index < pages.lastIndex) index++
                    else nav.navigate(Routes.LOGIN) {
                        popUpTo(Routes.ONBOARDING) { inclusive = true }
                    }
                }
            )
        }
    }
}

/** Общий заголовок для экранов авторизации. */
@Composable
fun AuthHeader(emoji: String, title: String, subtitle: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier
                .size(88.dp)
                .clip(CircleShape)
                .background(AppColors.PrimaryGradient),
            contentAlignment = Alignment.Center
        ) {
            Text(emoji, fontSize = 44.sp)
        }
        Spacer(Modifier.height(20.dp))
        Text(title, color = AppColors.TextPrimary, fontSize = 28.sp, fontWeight = FontWeight.W800)
        if (subtitle.isNotBlank()) {
            Spacer(Modifier.height(6.dp))
            Text(subtitle, color = AppColors.TextSecondary, fontSize = 15.sp, textAlign = TextAlign.Center)
        }
    }
}

/** Вход. */
@Composable
fun LoginScreen(nav: NavController) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var loading by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.Background)
            .verticalScroll(rememberScrollState())
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(Modifier.height(60.dp))
        AuthHeader("👋", "С возвращением!", "")
        Spacer(Modifier.height(24.dp))

        Image(
            painter = painterResource(id = com.gohavefun.app.R.drawable.cute_cat),
            contentDescription = "Милый котик",
            contentScale = ContentScale.Crop,
            modifier = Modifier
                .size(220.dp)
                .clip(RoundedCornerShape(24.dp))
        )
        Spacer(Modifier.height(28.dp))

        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("Email") },
            singleLine = true,
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(Modifier.height(14.dp))
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Пароль") },
            singleLine = true,
            visualTransformation = PasswordVisualTransformation(),
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(Modifier.height(24.dp))

        val haptic = LocalHapticFeedback.current

        AppButton(
            label = "Войти",
            isLoading = loading,
            onClick = {
                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                loading = true
                nav.navigate(Routes.PROFILE_SETUP)
            }
        )
        Spacer(Modifier.height(16.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text("Нет аккаунта?", color = AppColors.TextSecondary, fontSize = 14.sp)
            TextButton(onClick = { nav.navigate(Routes.REGISTER) }) {
                Text("Зарегистрироваться", color = AppColors.Primary, fontWeight = FontWeight.W700)
            }
        }
    }
}

/** Регистрация. */
@Composable
fun RegisterScreen(nav: NavController) {
    var name by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var loading by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.Background)
            .verticalScroll(rememberScrollState())
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(Modifier.height(60.dp))
        AuthHeader("🎉", "Создай аккаунт", "Пара минут — и ты в игре")
        Spacer(Modifier.height(36.dp))

        OutlinedTextField(
            value = name,
            onValueChange = { name = it },
            label = { Text("Имя") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(Modifier.height(14.dp))
        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("Email") },
            singleLine = true,
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(Modifier.height(14.dp))
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Пароль") },
            singleLine = true,
            visualTransformation = PasswordVisualTransformation(),
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(Modifier.height(24.dp))

        AppButton(
            label = "Зарегистрироваться",
            isLoading = loading,
            onClick = {
                loading = true
                nav.navigate(Routes.PROFILE_SETUP)
            }
        )
        Spacer(Modifier.height(16.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text("Уже есть аккаунт?", color = AppColors.TextSecondary, fontSize = 14.sp)
            TextButton(onClick = { nav.navigate(Routes.LOGIN) }) {
                Text("Войти", color = AppColors.Primary, fontWeight = FontWeight.W700)
            }
        }
    }
}

/** Настройка профиля (пол/возраст/о себе) перед входом на карту. */
@Composable
fun ProfileSetupScreen(nav: NavController) {
    var name by remember { mutableStateOf("") }
    var age by remember { mutableStateOf("") }
    var gender by remember { mutableStateOf("female") }
    var bio by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColors.Background)
            .verticalScroll(rememberScrollState())
            .padding(24.dp)
    ) {
        Spacer(Modifier.height(50.dp))
        Text("Расскажи о себе", color = AppColors.TextPrimary, fontSize = 26.sp, fontWeight = FontWeight.W800)
        Spacer(Modifier.height(6.dp))
        Text("Это увидят люди рядом", color = AppColors.TextSecondary, fontSize = 14.sp)
        Spacer(Modifier.height(28.dp))

        OutlinedTextField(
            value = name,
            onValueChange = { name = it },
            label = { Text("Имя") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(Modifier.height(14.dp))
        OutlinedTextField(
            value = age,
            onValueChange = { age = it.filter { c -> c.isDigit() } },
            label = { Text("Возраст") },
            singleLine = true,
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(Modifier.height(18.dp))

        Text("Пол", color = AppColors.TextPrimary, fontSize = 15.sp, fontWeight = FontWeight.W700)
        Spacer(Modifier.height(10.dp))
        Row(modifier = Modifier.fillMaxWidth()) {
            GenderChip("👩 Женский", gender == "female", Modifier.weight(1f)) { gender = "female" }
            Spacer(Modifier.width(12.dp))
            GenderChip("👨 Мужской", gender == "male", Modifier.weight(1f)) { gender = "male" }
        }
        Spacer(Modifier.height(18.dp))

        OutlinedTextField(
            value = bio,
            onValueChange = { if (it.length <= AppConstants.MAX_BIO_LENGTH) bio = it },
            label = { Text("О себе") },
            modifier = Modifier.fillMaxWidth().height(120.dp)
        )
        Spacer(Modifier.height(28.dp))

        AppButton(
            label = "На карту!",
            emoji = "🗺️",
            onClick = {
                nav.navigate(Routes.MAP) {
                    popUpTo(Routes.LOGIN) { inclusive = true }
                }
            }
        )
        Spacer(Modifier.height(24.dp))
    }
}

@Composable
private fun GenderChip(label: String, selected: Boolean, modifier: Modifier = Modifier, onClick: () -> Unit) {
    Box(
        modifier = modifier
            .height(50.dp)
            .clip(RoundedCornerShape(14.dp))
            .background(if (selected) AppColors.Primary else AppColors.Surface)
            .clickable { onClick() },
        contentAlignment = Alignment.Center
    ) {
        Text(
            label,
            color = if (selected) Color.White else AppColors.TextSecondary,
            fontWeight = FontWeight.W600,
            fontSize = 14.sp
        )
    }
}
