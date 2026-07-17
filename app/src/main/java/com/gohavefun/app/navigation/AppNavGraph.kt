package com.gohavefun.app.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.gohavefun.app.data.ThemeViewModel
import com.gohavefun.app.ui.screens.ChatExpiredScreen
import com.gohavefun.app.ui.screens.ChatScreen
import com.gohavefun.app.ui.screens.LoginScreen
import com.gohavefun.app.ui.screens.MainShell
import com.gohavefun.app.ui.screens.OnboardingScreen
import com.gohavefun.app.ui.screens.ProfileSetupScreen
import com.gohavefun.app.ui.screens.RegisterScreen
import com.gohavefun.app.ui.screens.SplashScreen

@Composable
fun AppNavGraph(themeVm: ThemeViewModel) {
    val nav = rememberNavController()

    NavHost(navController = nav, startDestination = Routes.SPLASH) {
        composable(Routes.SPLASH) { SplashScreen(nav) }
        composable(Routes.ONBOARDING) { OnboardingScreen(nav) }
        composable(Routes.LOGIN) { LoginScreen(nav) }
        composable(Routes.REGISTER) { RegisterScreen(nav) }
        composable(Routes.PROFILE_SETUP) { ProfileSetupScreen(nav) }

        // Основная оболочка (карта/пара/котики/профиль) с нижней навигацией
        composable(Routes.MAP) { MainShell(rootNav = nav, themeVm = themeVm) }

        // Чат (полноэкранный)
        composable(
            route = "${Routes.CHAT}/{chatId}",
            arguments = listOf(navArgument("chatId") { type = NavType.StringType })
        ) { backStackEntry ->
            val chatId = backStackEntry.arguments?.getString("chatId") ?: ""
            ChatScreen(nav, chatId)
        }

        composable(Routes.CHAT_EXPIRED) { ChatExpiredScreen(nav) }
    }
}
