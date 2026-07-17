package com.gohavefun.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gohavefun.app.ui.theme.AppColors

@Composable
fun ScreenContainer(
    modifier: Modifier = Modifier,
    backgroundColor: Color = AppColors.Background,
    verticalArrangement: Arrangement.Vertical = Arrangement.Top,
    horizontalAlignment: Alignment.Horizontal = Alignment.Start,
    content: @Composable ColumnScope.() -> Unit
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(backgroundColor),
        verticalArrangement = verticalArrangement,
        horizontalAlignment = horizontalAlignment,
        content = content
    )
}

@Composable
fun SectionHeader(
    title: String,
    subtitle: String? = null,
    modifier: Modifier = Modifier,
    titleColor: Color = AppColors.TextPrimary,
    subtitleColor: Color = AppColors.TextSecondary,
) {
    Column(modifier = modifier) {
        Text(title, color = titleColor, fontSize = 26.sp, fontWeight = FontWeight.W800)
        if (subtitle != null) {
            Spacer(Modifier.height(4.dp))
            Text(subtitle, color = subtitleColor, fontSize = 14.sp)
        }
    }
}

@Composable
fun AppCard(
    modifier: Modifier = Modifier,
    backgroundColor: Color = AppColors.Surface,
    cornerRadius: Dp = 16.dp,
    paddingValues: PaddingValues = PaddingValues(16.dp),
    content: @Composable () -> Unit
) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(cornerRadius))
            .background(backgroundColor)
            .padding(paddingValues)
    ) {
        content()
    }
}

@Composable
fun IconBadge(
    emoji: String,
    modifier: Modifier = Modifier,
    size: Dp = 48.dp,
    backgroundColor: Color = AppColors.SurfaceAlt,
    contentSize: androidx.compose.ui.unit.TextUnit = 24.sp,
) {
    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(backgroundColor),
        contentAlignment = Alignment.Center
    ) {
        Text(emoji, fontSize = contentSize)
    }
}

@Composable
fun FeatureRow(emoji: String, title: String, subtitle: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 6.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(AppColors.Surface)
            .padding(14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        IconBadge(emoji, modifier = Modifier.size(48.dp), contentSize = 24.sp)
        Spacer(Modifier.width(14.dp))
        Column {
            Text(title, color = AppColors.TextPrimary, fontSize = 15.sp, fontWeight = FontWeight.W700)
            Text(subtitle, color = AppColors.TextSecondary, fontSize = 13.sp)
        }
    }
}

@Composable
fun StatCard(value: String, label: String, modifier: Modifier = Modifier) {
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
fun SettingRow(emoji: String, title: String, modifier: Modifier = Modifier, onClick: () -> Unit = {}) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = 5.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(AppColors.Surface)
            .clickable { onClick() }
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(emoji, fontSize = 20.sp)
        Spacer(Modifier.width(14.dp))
        Text(title, color = AppColors.TextPrimary, fontSize = 15.sp, fontWeight = FontWeight.W600, modifier = Modifier.weight(1f))
        Text("›", color = AppColors.TextSecondary, fontSize = 22.sp)
    }
}

@Composable
fun CatListItem(emoji: String, name: String, desc: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 6.dp)
            .clip(RoundedCornerShape(18.dp))
            .background(AppColors.Surface)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        IconBadge(emoji, modifier = Modifier.size(64.dp), contentSize = 36.sp)
        Spacer(Modifier.width(16.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(name, color = AppColors.TextPrimary, fontSize = 17.sp, fontWeight = FontWeight.W700)
            Text(desc, color = AppColors.TextSecondary, fontSize = 13.sp)
        }
        Text("❤️", fontSize = 22.sp)
    }
}
