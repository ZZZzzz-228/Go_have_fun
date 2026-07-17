package com.gohavefun.app.data

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlin.random.Random

data class MapState(
    val nearbyUsers: List<MapUser> = emptyList(),
    val safeZones: List<SafeZone> = emptyList(),
    val isSearchActive: Boolean = false,
    val searchSecondsRemaining: Int = AppConstants.SEARCH_SESSION_DURATION,
    val currentBeaconEmoji: String? = null,
    val currentBeaconText: String? = null,
    val isPanicMode: Boolean = false,
    val currentUserGender: String = "female",
    val streetName: String = "Твоё местоположение",
    val temperatureC: Int? = 21,
    val weatherEmoji: String = "☀️",
    val ignoredUserIds: Set<String> = emptySet(),
    val activeMatchUserId: String? = null,
)

/**
 * Логика экрана карты. Перенесено из Flutter (MapNotifier).
 * Настоящая карта/геолокация заменены схематичным представлением и mock-данными,
 * чтобы приложение работало без внешних сервисов и ключей.
 */
class MapViewModel : ViewModel() {

    private val _state = MutableStateFlow(MapState())
    val state: StateFlow<MapState> = _state.asStateFlow()

    private var searchJob: Job? = null

    init {
        _state.value = _state.value.copy(safeZones = mockSafeZones())
    }

    fun setGender(gender: String) {
        _state.value = _state.value.copy(currentUserGender = gender)
    }

    fun startSearchSession() {
        _state.value = _state.value.copy(
            isSearchActive = true,
            searchSecondsRemaining = AppConstants.SEARCH_SESSION_DURATION,
            nearbyUsers = mockUsers(),
        )
        searchJob?.cancel()
        searchJob = viewModelScope.launch {
            while (_state.value.searchSecondsRemaining > 0 && _state.value.isSearchActive) {
                delay(1000)
                val remaining = _state.value.searchSecondsRemaining - 1
                if (remaining <= 0) {
                    stopSearchSession()
                } else {
                    _state.value = _state.value.copy(searchSecondsRemaining = remaining)
                }
            }
        }
    }

    fun stopSearchSession() {
        searchJob?.cancel()
        _state.value = _state.value.copy(
            isSearchActive = false,
            searchSecondsRemaining = AppConstants.SEARCH_SESSION_DURATION,
            nearbyUsers = emptyList(),
            activeMatchUserId = null,
        )
    }

    fun setBeacon(emoji: String, text: String) {
        _state.value = _state.value.copy(currentBeaconEmoji = emoji, currentBeaconText = text)
    }

    fun skipMatch(userId: String) {
        _state.value = _state.value.copy(
            ignoredUserIds = _state.value.ignoredUserIds + userId,
            nearbyUsers = _state.value.nearbyUsers.filter { it.userId != userId },
            activeMatchUserId = null,
        )
    }

    fun activatePanic() {
        searchJob?.cancel()
        _state.value = _state.value.copy(
            isPanicMode = true,
            isSearchActive = false,
            nearbyUsers = emptyList(),
        )
        viewModelScope.launch {
            delay(30_000)
            _state.value = _state.value.copy(isPanicMode = false)
        }
    }

    // ===== Mock данные =====

    private fun mockUsers(): List<MapUser> {
        val names = listOf("Анна", "Мария", "Дмитрий", "Алексей", "Юлия", "Кирилл", "Наташа", "Иван")
        val genders = listOf("female", "female", "male", "male")
        val beacons = listOf(
            "☕" to "Ищу с кем выпить кофе",
            "🚶" to "Просто гуляю",
            "🍺" to "Идём в бар",
            "🎸" to "На концерт вместе",
        )
        val count = 3 + Random.nextInt(5)
        val list = (0 until count).map { i ->
            val beacon = beacons.random()
            MapUser(
                userId = "mock_$i",
                name = names.random(),
                age = 18 + Random.nextInt(15),
                gender = genders.random(),
                beaconEmoji = beacon.first,
                beaconText = beacon.second,
                distanceMeters = 20 + Random.nextDouble() * 80,
                batteryLevel = 15 + Random.nextInt(85),
                relX = 0.15f + Random.nextFloat() * 0.7f,
                relY = 0.15f + Random.nextFloat() * 0.6f,
            )
        }
        // Показываем противоположный пол (как во Flutter-версии)
        val g = _state.value.currentUserGender
        return list.filter {
            when (g) {
                "male" -> it.gender == "female"
                "female" -> it.gender == "male"
                else -> true
            }
        }.ifEmpty { list }
    }

    private fun mockSafeZones(): List<SafeZone> = listOf(
        SafeZone("sz1", "Кофейня «Утро»", "☕", 0.7f, 0.3f),
        SafeZone("sz2", "Бар «Пятница»", "🍺", 0.3f, 0.65f),
        SafeZone("sz3", "Парк «Центральный»", "🌳", 0.55f, 0.8f),
    )
}
