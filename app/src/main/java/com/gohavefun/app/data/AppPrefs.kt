package com.gohavefun.app.data

import android.content.Context

/** Простое локальное хранилище (аналог SharedPreferences во Flutter-версии). */
class AppPrefs(context: Context) {
    private val prefs = context.getSharedPreferences("go_have_fun", Context.MODE_PRIVATE)

    var isOnboarded: Boolean
        get() = prefs.getBoolean("is_onboarded", false)
        set(value) = prefs.edit().putBoolean("is_onboarded", value).apply()

    var userId: String?
        get() = prefs.getString("user_id", null)
        set(value) = prefs.edit().putString("user_id", value).apply()

    var darkTheme: Boolean
        get() = prefs.getBoolean("dark_theme", false)
        set(value) = prefs.edit().putBoolean("dark_theme", value).apply()

    fun clearUser() {
        prefs.edit().remove("user_id").apply()
    }
}
