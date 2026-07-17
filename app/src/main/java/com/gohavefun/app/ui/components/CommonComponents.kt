package com.gohavefun.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gohavefun.app.ui.theme.AppColors

/** Главная градиентная кнопка (аналог AppButton во Flutter-версии). */
@Composable
fun AppButton(
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    emoji: String? = null,
    isLoading: Boolean = false,
    enabled: Boolean = true,
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(54.dp)
            .clip(RoundedCornerShape(18.dp))
            .background(AppColors.PrimaryGradient)
            .clickable(enabled = enabled && !isLoading) { onClick() },
        contentAlignment = Alignment.Center
    ) {
        if (isLoading) {
            CircularProgressIndicator(
                color = Color.White,
                strokeWidth = 2.5.dp,
                modifier = Modifier.size(24.dp)
            )
        } else {
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (emoji != null) {
                    Text(emoji, fontSize = 18.sp)
                    Spacer(Modifier.width(8.dp))
                }
                Text(
                    label,
                    color = Color.White,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.W700
                )
            }
        }
    }
}

/** Круглая плавающая кнопка на карте. */
@Composable
fun MapFab(
    onClick: () -> Unit,
    gradient: Boolean = false,
    bg: Color = AppColors.Surface,
    content: @Composable () -> Unit,
) {
    Box(
        modifier = Modifier
            .size(52.dp)
            .clip(CircleShape)
            .then(
                if (gradient) Modifier.background(AppColors.PrimaryGradient)
                else Modifier.background(bg)
            )
            .clickable { onClick() },
        contentAlignment = Alignment.Center
    ) { content() }
}
