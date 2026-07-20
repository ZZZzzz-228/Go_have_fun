<<<<<<< Updated upstream
<<<<<<< Updated upstream
package com.gohavefun.app.ui.screens.main

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Column
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
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.gohavefun.app.data.AppConstants
import com.gohavefun.app.data.ThemeViewModel
import com.gohavefun.app.navigation.Routes
import com.gohavefun.app.ui.components.AppButton
import com.gohavefun.app.ui.components.AppCard
import com.gohavefun.app.ui.components.CatListItem
import com.gohavefun.app.ui.components.FeatureRow
import com.gohavefun.app.ui.components.IconBadge
import com.gohavefun.app.ui.components.ScreenContainer
import com.gohavefun.app.ui.components.SectionHeader
import com.gohavefun.app.ui.components.SettingRow
import com.gohavefun.app.ui.components.StatCard
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

@Composable
fun CatsScreen() {
    val cats = listOf(
        Triple("🐱", "Барсик", "Ищет хозяина для игр"),
        Triple("🐈", "Мурка", "Обожает солнечные подоконники"),
        Triple("😺", "Рыжик", "Мастер сбивать вещи со стола"),
        Triple("🐈‍⬛", "Уголёк", "Ночной охотник за лазером"),
        Triple("😻", "Ласка", "Мурчит громче холодильника"),
    )
    ScreenContainer(modifier = Modifier.verticalScroll(rememberScrollState())) {
        Column(modifier = Modifier.statusBarsPadding().padding(20.dp)) {
            SectionHeader("Котики дня 🐾", "Немного тепла, пока ищешь встречу")
            Spacer(Modifier.height(16.dp))
            cats.forEach { (emoji, name, desc) ->
                CatListItem(emoji, name, desc)
            }
            Spacer(Modifier.height(24.dp))
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

=======
package com.gohavefun.app.ui.screens.main

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.gestures.waitForUpOrCancellation
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.input.pointer.changedToUpIgnoreConsumed
import androidx.compose.ui.input.pointer.positionChange
import androidx.compose.ui.input.pointer.util.VelocityTracker
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.util.lerp
import androidx.navigation.NavController
import com.gohavefun.app.data.AppConstants
import com.gohavefun.app.data.ThemeViewModel
import com.gohavefun.app.navigation.Routes
import com.gohavefun.app.ui.components.AppButton
import com.gohavefun.app.ui.components.AppCard
import com.gohavefun.app.ui.components.CatListItem
import com.gohavefun.app.ui.components.FeatureRow
import com.gohavefun.app.ui.components.IconBadge
import com.gohavefun.app.ui.components.ScreenContainer
import com.gohavefun.app.ui.components.SectionHeader
import com.gohavefun.app.ui.components.SettingRow
import com.gohavefun.app.ui.components.StatCard
import com.gohavefun.app.ui.screens.map.MapScreen
import com.gohavefun.app.ui.theme.AppColors
import com.kyant.backdrop.Backdrop
import com.kyant.backdrop.drawBackdrop
import com.kyant.backdrop.backdrops.layerBackdrop
import com.kyant.backdrop.backdrops.rememberLayerBackdrop
import com.kyant.backdrop.effects.blur
import com.kyant.backdrop.effects.lens
import com.kyant.backdrop.effects.vibrancy
import kotlinx.coroutines.launch
import androidx.compose.animation.core.Spring
import androidx.compose.foundation.layout.offset
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import kotlin.math.roundToInt
@Composable
fun MainShell(rootNav: NavController, themeVm: ThemeViewModel) {
    var currentIndex by remember { mutableStateOf(0) }

    Box(modifier = Modifier.fillMaxSize().background(AppColors.Background)) {
        // Бэкдроп: захватывает всё, что нарисовано под таб-баром, чтобы стекло
        // могло его размыть/преломить. Экраны рисуются на всю высоту (без
        // отступа снизу под бар) — именно так стекло "видит" реальный контент,
        // а не пустой фон. Поэтому каждый экран сам добавляет отступ под
        // последним элементом, чтобы контент не терялся под баром.
        val backdrop = rememberLayerBackdrop {
            drawRect(AppColors.Background)
            drawContent()
        }

        Box(
            modifier = Modifier
                .fillMaxSize()
                .layerBackdrop(backdrop)
        ) {
            when (currentIndex) {
                0 -> MapScreen(rootNav)
                1 -> CoupleScreen(onOpenMap = { currentIndex = 0 })
                2 -> CatsScreen()
                3 -> ProfileScreen(rootNav, themeVm)
            }
        }

        BottomBar(
            backdrop = backdrop,
            currentIndex = currentIndex,
            onSelect = { currentIndex = it },
            modifier = Modifier.align(Alignment.BottomCenter)
        )
    }
}

// Публичные размеры плавающей стеклянной стойки — экраны используют их,
// чтобы поднимать свои плавающие кнопки/CTA НАД баром (сам MainShell не
// резервирует место снизу под контент, т.к. это нужно бэкдропу для захвата
// реального контента под стеклом).
val MainBottomBarHeight = 78.dp
val MainBottomBarVerticalMargin = 12.dp

private data class NavItem(val emoji: String, val label: String)

private val TabItemShape = RoundedCornerShape(36.dp)

@Composable
private fun BottomBar(
    backdrop: Backdrop,
    currentIndex: Int,
    onSelect: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    val items = listOf(
        NavItem("🗺️", "Карта"),
        NavItem("💞", "Пара"),
        NavItem("🐱", "Котики"),
        NavItem("👤", "Профиль"),
    )
    val itemCount = items.size

    val configuration = LocalConfiguration.current
    val density = LocalDensity.current
    val itemWidth = (configuration.screenWidthDp.dp - 32.dp) / itemCount
    val itemWidthPx = with(density) { itemWidth.toPx() }
    val maxOffsetPx = itemWidthPx * (itemCount - 1)

    // Позиция стеклянной таблетки в пикселях — во время жеста это источник истины,
    // двигается напрямую пальцем, без задержки на пересчёт состояния.
    val offsetX = remember(itemWidthPx) { Animatable(itemWidthPx * currentIndex) }
    // Растяжение/сжатие "вязкого стекла" по X и Y — эффект жидкой деформации.
    val morphX = remember { Animatable(1f) }
    val morphY = remember { Animatable(1f) }

    val scope = rememberCoroutineScope()
    var isDragging by remember { mutableStateOf(false) }
    var selfDrivenIndex by remember { mutableStateOf(currentIndex) }
    val velocityTracker = remember { VelocityTracker() }

    // Если таб сменился СНАРУЖИ (например кнопка "Перейти к карте" в CoupleScreen),
    // а не жестом/тапом по самой стойке — плавно подтягиваем стекло к нему.
    LaunchedEffect(currentIndex) {
        if (!isDragging && currentIndex != selfDrivenIndex) {
            selfDrivenIndex = currentIndex
            offsetX.animateTo(
                targetValue = itemWidthPx * currentIndex,
                animationSpec = spring(stiffness = Spring.StiffnessVeryLow, dampingRatio = 0.78f)
            )
        }
    }

    // Довести таблетку до ближайшего таба с пружиной (с учётом скорости пальца —
    // "долёт по инерции") и переключить экран.
    fun settleTo(index: Int, initialVelocity: Float) {
        val clamped = index.coerceIn(0, itemCount - 1)
        selfDrivenIndex = clamped
        onSelect(clamped)
        scope.launch {
            offsetX.animateTo(
                targetValue = itemWidthPx * clamped,
                animationSpec = spring(
                    dampingRatio = Spring.DampingRatioMediumBouncy,
                    stiffness = Spring.StiffnessLow
                ),
                initialVelocity = initialVelocity
            )
        }
        scope.launch {
            morphX.animateTo(1f, spring(dampingRatio = Spring.DampingRatioHighBouncy, stiffness = Spring.StiffnessMedium))
        }
        scope.launch {
            morphY.animateTo(1f, spring(dampingRatio = Spring.DampingRatioHighBouncy, stiffness = Spring.StiffnessMedium))
        }
    }

    Box(
        modifier = modifier
            .fillMaxWidth()
            .navigationBarsPadding()
            .padding(horizontal = 16.dp, vertical = 12.dp)
            .height(78.dp)
            // Единый обработчик жеста на ВСЮ стойку: тянуть слайдер можно, взявшись
            // за любое место бара (не только за саму таблетку), а обычный тап
            // по любой точке выбирает ближайший таб. Так тап-зоны иконок никогда
            // не перехватывают палец раньше жеста перетаскивания.
            .pointerInput(itemCount, itemWidthPx) {
                awaitEachGesture {
                    val down = awaitFirstDown(requireUnconsumed = false)
                    velocityTracker.resetTracking()
                    velocityTracker.addPosition(down.uptimeMillis, down.position)
                    val downIndex = (down.position.x / itemWidthPx).toInt().coerceIn(0, itemCount - 1)
                    val touchSlop = viewConfiguration.touchSlop
                    var dragStarted = false
                    var totalDrag = 0f

                    while (true) {
                        val event = awaitPointerEvent()
                        val change = event.changes.firstOrNull { it.id == down.id } ?: break

                        if (change.changedToUpIgnoreConsumed()) {
                            change.consume()
                            if (!dragStarted) {
                                settleTo(downIndex, 0f)
                            } else {
                                isDragging = false
                                val velocityPxPerSec = velocityTracker.calculateVelocity().x
                                // Куда "долетит" по инерции — так решаем, на каком табе отпустить
                                val projected = offsetX.value + velocityPxPerSec * 0.12f
                                val targetIndex = (projected / itemWidthPx).roundToInt()
                                settleTo(targetIndex, velocityPxPerSec)
                            }
                            break
                        }

                        val dragAmount = change.positionChange().x
                        totalDrag += dragAmount
                        velocityTracker.addPosition(change.uptimeMillis, change.position)

                        if (!dragStarted && kotlin.math.abs(totalDrag) > touchSlop) {
                            dragStarted = true
                            isDragging = true
                        }

                        if (dragStarted) {
                            change.consume()
                            val rawTarget = offsetX.value + dragAmount
                            // Резиновое сопротивление за пределами первого/последнего таба
                            val clampedTarget = when {
                                rawTarget < 0f -> rawTarget * 0.35f
                                rawTarget > maxOffsetPx -> maxOffsetPx + (rawTarget - maxOffsetPx) * 0.35f
                                else -> rawTarget
                            }
                            // Морфинг: чем резче тянешь, тем сильнее "вытягивается" стекло
                            // по X и сжимается по Y — как капля вязкой жидкости.
                            val stretch = (dragAmount / 14f).coerceIn(-0.6f, 0.6f)
                            scope.launch { offsetX.snapTo(clampedTarget) }
                            scope.launch {
                                morphX.snapTo((1f + kotlin.math.abs(stretch)).coerceIn(1f, 1.6f))
                                morphY.snapTo((1f - kotlin.math.abs(stretch) * 0.35f).coerceIn(0.7f, 1f))
                            }
                        }
                    }
                }
            }
            // Стеклянная "стойка" целиком — видимая подложка под всеми кнопками,
            // как барная стойка со стеклянным дном на референсе.
            .drawBackdrop(
                backdrop = backdrop,
                shape = { RoundedCornerShape(32.dp) },
                effects = {
                    vibrancy()
                    blur(10f.dp.toPx())
                },
                onDrawSurface = {
                    drawRect(Color.White.copy(alpha = 0.12f))
                    drawRect(
                        brush = Brush.verticalGradient(
                            listOf(
                                Color.White.copy(alpha = 0.24f),
                                Color.White.copy(alpha = 0.05f)
                            )
                        ),
                        size = Size(size.width, size.height * 0.55f)
                    )
                    drawRoundRect(
                        color = Color.White.copy(alpha = 0.38f),
                        cornerRadius = CornerRadius(32.dp.toPx()),
                        style = Stroke(width = 1.dp.toPx())
                    )
                }
            )
    ) {
        // Liquid Glass Индикатор — тянется пальцем влево/вправо, тянется и пружинит,
        // как вязкое жидкое стекло, и преломляет (lens) то, что под ним.
        // Сам жест ловится на внешней стойке выше — здесь только визуал.
        Box(
            modifier = Modifier
                .offset { IntOffset(offsetX.value.roundToInt(), 0) }
                .width(itemWidth)
                .fillMaxHeight()
                .padding(4.dp)
                .graphicsLayer {
                    scaleX = morphX.value
                    scaleY = morphY.value
                }
                .drawBackdrop(
                    backdrop = backdrop,
                    shape = { RoundedCornerShape(28.dp) },
                    effects = {
                        vibrancy()
                        blur(8f.dp.toPx())
                        lens(22f.dp.toPx(), 28f.dp.toPx())
                    },
                    onDrawSurface = {
                        // Основной цвет стекла
                        drawRect(Color.White.copy(alpha = 0.03f))

                        // Верхний блик (Liquid эффект)
                        drawRect(
                            brush = Brush.verticalGradient(
                                listOf(
                                    Color.White.copy(alpha = 0.38f),
                                    Color.White.copy(alpha = 0.06f)
                                )
                            ),
                            size = Size(size.width, size.height * 0.5f)
                        )

                        // Тонкая обводка как в iOS
                        drawRoundRect(
                            color = Color.White.copy(alpha = 0.45f),
                            cornerRadius = CornerRadius(28.dp.toPx()),
                            style = Stroke(width = 1.2f.dp.toPx())
                        )
                    }
                )
        )

        // Иконки и текст — чисто визуальные, без своих кликов (жест выше решает,
        // какой таб выбран — и по тапу, и по перетаскиванию).
        Row(
            modifier = Modifier.fillMaxSize(),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            items.forEachIndexed { i, item ->
                val selected = i == currentIndex

                Column(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Text(
                        text = item.emoji,
                        fontSize = if (selected) 26.sp else 22.sp,
                        color = if (selected) Color.White else Color.White.copy(alpha = 0.7f)
                    )
                    Spacer(Modifier.height(4.dp))
                    Text(
                        text = item.label,
                        fontSize = 11.sp,
                        fontWeight = if (selected) FontWeight.W700 else FontWeight.W500,
                        color = if (selected) Color.White else Color.White.copy(alpha = 0.7f)
                    )
                }
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
        Spacer(Modifier.height(120.dp))
    }
}

@Composable
fun CatsScreen() {
    val cats = listOf(
        Triple("🐱", "Барсик", "Ищет хозяина для игр"),
        Triple("🐈", "Мурка", "Обожает солнечные подоконники"),
        Triple("😺", "Рыжик", "Мастер сбивать вещи со стола"),
        Triple("🐈‍⬛", "Уголёк", "Ночной охотник за лазером"),
        Triple("😻", "Ласка", "Мурчит громче холодильника"),
    )
    ScreenContainer(modifier = Modifier.verticalScroll(rememberScrollState())) {
        Column(modifier = Modifier.statusBarsPadding().padding(20.dp)) {
            SectionHeader("Котики дня 🐾", "Немного тепла, пока ищешь встречу")
            Spacer(Modifier.height(16.dp))
            cats.forEach { (emoji, name, desc) ->
                CatListItem(emoji, name, desc)
            }
            Spacer(Modifier.height(120.dp))
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
            Spacer(Modifier.height(120.dp))
        }
    }
}
>>>>>>> Stashed changes
=======
package com.gohavefun.app.ui.screens.main

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.waitForUpOrCancellation
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.util.lerp
import androidx.navigation.NavController
import com.gohavefun.app.data.AppConstants
import com.gohavefun.app.data.ThemeViewModel
import com.gohavefun.app.navigation.Routes
import com.gohavefun.app.ui.components.AppButton
import com.gohavefun.app.ui.components.AppCard
import com.gohavefun.app.ui.components.CatListItem
import com.gohavefun.app.ui.components.FeatureRow
import com.gohavefun.app.ui.components.IconBadge
import com.gohavefun.app.ui.components.ScreenContainer
import com.gohavefun.app.ui.components.SectionHeader
import com.gohavefun.app.ui.components.SettingRow
import com.gohavefun.app.ui.components.StatCard
import com.gohavefun.app.ui.screens.map.MapScreen
import com.gohavefun.app.ui.theme.AppColors
import com.kyant.backdrop.Backdrop
import com.kyant.backdrop.drawBackdrop
import com.kyant.backdrop.backdrops.layerBackdrop
import com.kyant.backdrop.backdrops.rememberLayerBackdrop
import com.kyant.backdrop.effects.blur
import com.kyant.backdrop.effects.lens
import com.kyant.backdrop.effects.vibrancy
import kotlinx.coroutines.launch
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.layout.offset
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.unit.dp
@Composable
fun MainShell(rootNav: NavController, themeVm: ThemeViewModel) {
    var currentIndex by remember { mutableStateOf(0) }

    Box(modifier = Modifier.fillMaxSize().background(AppColors.Background)) {
        // Бэкдроп: захватывает всё, что нарисовано под таб-баром, чтобы стекло
        // могло его размыть/преломить. Экраны рисуются на всю высоту (без
        // отступа снизу под бар) — именно так стекло "видит" реальный контент,
        // а не пустой фон. Поэтому каждый экран сам добавляет отступ под
        // последним элементом, чтобы контент не терялся под баром.
        val backdrop = rememberLayerBackdrop {
            drawRect(AppColors.Background)
            drawContent()
        }

        Box(
            modifier = Modifier
                .fillMaxSize()
                .layerBackdrop(backdrop)
        ) {
            when (currentIndex) {
                0 -> MapScreen(rootNav)
                1 -> CoupleScreen(onOpenMap = { currentIndex = 0 })
                2 -> CatsScreen()
                3 -> ProfileScreen(rootNav, themeVm)
            }
        }

        BottomBar(
            backdrop = backdrop,
            currentIndex = currentIndex,
            onSelect = { currentIndex = it },
            modifier = Modifier.align(Alignment.BottomCenter)
        )
    }
}

private data class NavItem(val emoji: String, val label: String)

private val TabItemShape = RoundedCornerShape(36.dp)

@Composable
private fun BottomBar(
    backdrop: Backdrop,
    currentIndex: Int,
    onSelect: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    val items = listOf(
        NavItem("🗺️", "Карта"),
        NavItem("💞", "Пара"),
        NavItem("🐱", "Котики"),
        NavItem("👤", "Профиль"),
    )

    val configuration = LocalConfiguration.current
    val itemWidth = (configuration.screenWidthDp.dp - 32.dp) / items.size

    val indicatorOffset by animateDpAsState(
        targetValue = itemWidth * currentIndex,
        animationSpec = spring(
            stiffness = Spring.StiffnessVeryLow,
            dampingRatio = 0.78f
        )
    )

    Box(
        modifier = modifier
            .fillMaxWidth()
            .navigationBarsPadding()
            .padding(horizontal = 16.dp, vertical = 12.dp)
            .height(78.dp)
    ) {
        // Liquid Glass Индикатор
        Box(
            modifier = Modifier
                .offset(x = indicatorOffset)
                .width(itemWidth)
                .fillMaxHeight()
                .drawBackdrop(
                    backdrop = backdrop,
                    shape = { RoundedCornerShape(32.dp) },
                    effects = {
                        vibrancy()
                        blur(8f.dp.toPx())
                        lens(22f.dp.toPx(), 28f.dp.toPx())
                    },
                    onDrawSurface = {
                        // Основной цвет стекла
                        drawRect(Color.White.copy(alpha = 0.03f))

                        // Верхний блик (Liquid эффект)
                        drawRect(
                            brush = Brush.verticalGradient(
                                listOf(
                                    Color.White.copy(alpha = 0.38f),
                                    Color.White.copy(alpha = 0.06f)
                                )
                            ),
                            size = Size(size.width, size.height * 0.5f)
                        )

                        // Тонкая обводка как в iOS
                        drawRoundRect(
                            color = Color.White.copy(alpha = 0.45f),
                            cornerRadius = CornerRadius(32.dp.toPx()),
                            style = Stroke(width = 1.2f.dp.toPx())
                        )
                    }
                )
        )

        // Иконки и текст
        Row(
            modifier = Modifier.fillMaxSize(),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            items.forEachIndexed { i, item ->
                val selected = i == currentIndex

                Column(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight()
                        .clickable(interactionSource = null, indication = null) { onSelect(i) },
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Text(
                        text = item.emoji,
                        fontSize = if (selected) 26.sp else 22.sp,
                        color = if (selected) Color.White else Color.White.copy(alpha = 0.7f)
                    )
                    Spacer(Modifier.height(4.dp))
                    Text(
                        text = item.label,
                        fontSize = 11.sp,
                        fontWeight = if (selected) FontWeight.W700 else FontWeight.W500,
                        color = if (selected) Color.White else Color.White.copy(alpha = 0.7f)
                    )
                }
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
        Spacer(Modifier.height(120.dp))
    }
}

@Composable
fun CatsScreen() {
    val cats = listOf(
        Triple("🐱", "Барсик", "Ищет хозяина для игр"),
        Triple("🐈", "Мурка", "Обожает солнечные подоконники"),
        Triple("😺", "Рыжик", "Мастер сбивать вещи со стола"),
        Triple("🐈‍⬛", "Уголёк", "Ночной охотник за лазером"),
        Triple("😻", "Ласка", "Мурчит громче холодильника"),
    )
    ScreenContainer(modifier = Modifier.verticalScroll(rememberScrollState())) {
        Column(modifier = Modifier.statusBarsPadding().padding(20.dp)) {
            SectionHeader("Котики дня 🐾", "Немного тепла, пока ищешь встречу")
            Spacer(Modifier.height(16.dp))
            cats.forEach { (emoji, name, desc) ->
                CatListItem(emoji, name, desc)
            }
            Spacer(Modifier.height(120.dp))
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
            Spacer(Modifier.height(120.dp))
        }
    }
}
>>>>>>> Stashed changes
