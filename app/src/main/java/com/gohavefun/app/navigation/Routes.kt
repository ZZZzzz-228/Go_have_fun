package com.gohavefun.app.navigation

/** Имена маршрутов. Перенесено из Flutter (RouteNames). */
object Routes {
    const val SPLASH = "splash"
    const val ONBOARDING = "onboarding"
    const val LOGIN = "login"
    const val REGISTER = "register"
    const val PROFILE_SETUP = "profile_setup"

    // Табы главной оболочки
    const val MAP = "map"

    // Чат (полноэкранный)
    const val CHAT = "chat"                 // + "/{chatId}"
    const val CHAT_EXPIRED = "chat_expired"
}
