package com.gohavefun.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.gohavefun.app.data.ThemeViewModel
import com.gohavefun.app.navigation.AppNavGraph
import com.gohavefun.app.ui.theme.AppColors
import com.gohavefun.app.ui.theme.GoHaveFunTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        setContent { GoHaveFunApp() }
    }
}

@Composable
fun GoHaveFunApp() {
    val themeVm: ThemeViewModel = viewModel()
    val isDark by themeVm.isDark.collectAsState()

    GoHaveFunTheme(darkTheme = isDark) {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = if (isDark) AppColors.DarkBackground else AppColors.Background
        ) {
            AppNavGraph(themeVm = themeVm)
        }
    }
}
