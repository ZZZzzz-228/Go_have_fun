package com.gohavefun.app.data

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/** Управление тёмной темой (аналог themeModeProvider). */
class ThemeViewModel(app: Application) : AndroidViewModel(app) {
    private val prefs = AppPrefs(app)

    private val _isDark = MutableStateFlow(prefs.darkTheme)
    val isDark: StateFlow<Boolean> = _isDark.asStateFlow()

    fun toggle() {
        val newValue = !_isDark.value
        _isDark.value = newValue
        prefs.darkTheme = newValue
    }
}
