package com.gohavefun.app.data

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlin.math.*
import kotlin.random.Random

/**
 * Текущее состояние экрана карты.
 */
data class MapState(
    val nearbyUsers: List<MapUser> = emptyList(),
    val safeZones: List<SafeZone> = emptyList(),
    val photoPins: List<MapPhoto> = emptyList(),
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
    val selectedPhotoId: String? = null,
    val currentLatitude: Double? = null,
    val currentLongitude: Double? = null,
    val locationStatus: String = "Ищем местоположение..."
)

/**
 * Логика экрана карты.
 */
class MapViewModel : ViewModel() {

    private val _state = MutableStateFlow(MapState())
    val state: StateFlow<MapState> = _state.asStateFlow()

    private var searchJob: Job? = null

    init {
        _state.value = _state.value.copy(
            safeZones = mockSafeZones(),
            photoPins = mockPhotoPins(),
        )
    }

    private fun mockSafeZones(): List<SafeZone> = listOf(
        SafeZone("sz1", "Кофейня «Утро»", "☕", 0.7f, 0.3f),
        SafeZone("sz2", "Бар «Пятница»", "🍺", 0.3f, 0.65f),
        SafeZone("sz3", "Парк «Центральный»", "🌳", 0.55f, 0.8f),
    )

    fun setGender(gender: String) {
        _state.value = _state.value.copy(currentUserGender = gender)
    }

    fun hasLocationPermission(context: Context): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
    }

    fun loadLastLocation(context: Context) {
        if (!hasLocationPermission(context)) {
            _state.value = _state.value.copy(locationStatus = "Разрешите геолокацию")
            return
        }

        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager
        if (locationManager == null) {
            _state.value = _state.value.copy(locationStatus = "Не удалось получить службу геолокации")
            return
        }

        val providers = listOf(LocationManager.GPS_PROVIDER, LocationManager.NETWORK_PROVIDER)
        val lastLocation = providers.mapNotNull {
            try {
                locationManager.getLastKnownLocation(it)
            } catch (_: Throwable) {
                null
            }
        }.firstOrNull()

        if (lastLocation != null) {
            _state.value = _state.value.copy(
                currentLatitude = lastLocation.latitude,
                currentLongitude = lastLocation.longitude,
                locationStatus = "Позиция найдена"
            )
        } else {
            _state.value = _state.value.copy(
                locationStatus = "Не удалось найти последнюю позицию"
            )
        }
    }

    fun startSearchSession() {
        _state.value = _state.value.copy(
            isSearchActive = true,
            searchSecondsRemaining = AppConstants.SEARCH_SESSION_DURATION,
            nearbyUsers = generateNearbyUsers()
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
            activeMatchUserId = null
        )
    }

    fun setBeacon(emoji: String, text: String) {
        _state.value = _state.value.copy(currentBeaconEmoji = emoji, currentBeaconText = text)
    }

    fun skipMatch(userId: String) {
        _state.value = _state.value.copy(
            ignoredUserIds = _state.value.ignoredUserIds + userId,
            nearbyUsers = _state.value.nearbyUsers.filter { it.userId != userId },
            activeMatchUserId = null
        )
    }

    fun activatePanic() {
        searchJob?.cancel()
        _state.value = _state.value.copy(
            isPanicMode = true,
            isSearchActive = false,
            nearbyUsers = emptyList()
        )
        viewModelScope.launch {
            delay(30_000)
            _state.value = _state.value.copy(isPanicMode = false)
        }
    }

    fun addCatPhoto(caption: String) {
        val currentLocation = makeLocation(_state.value.currentLatitude, _state.value.currentLongitude)
        val distance = 15.0 + Random.nextDouble(5.0)
        val bearing = Random.nextDouble(360.0)
        val targetCoords = calculateOffset(currentLocation.latitude, currentLocation.longitude, distance, bearing)
        val targetLocation = Location("").apply {
            latitude = targetCoords.first
            longitude = targetCoords.second
        }
        val rel = latLonToRel(currentLocation, targetLocation)
        val newPhoto = MapPhoto(
            id = "photo_${_state.value.photoPins.size + 1}_${System.currentTimeMillis()}",
            userId = "user_${_state.value.photoPins.size + 1}",
            ownerName = if (_state.value.currentUserGender == "male") "Парень" else "Девушка",
            caption = caption,
            imageRes = com.gohavefun.app.R.drawable.cute_cat,
            distanceMeters = distance,
            relX = rel.first,
            relY = rel.second
        )
        _state.value = _state.value.copy(photoPins = _state.value.photoPins + newPhoto)
    }

    fun selectPhoto(photoId: String) {
        _state.value = _state.value.copy(selectedPhotoId = photoId)
    }

    fun closePhotoViewer() {
        _state.value = _state.value.copy(selectedPhotoId = null)
    }

    private fun generateNearbyUsers(): List<MapUser> {
        val currentLocation = makeLocation(_state.value.currentLatitude, _state.value.currentLongitude)
        val gender = if (_state.value.currentUserGender == "male") "female" else "male"
        return listOf(mockNearbyUser(currentLocation, gender))
    }

    private fun makeLocation(latitude: Double?, longitude: Double?): Location {
        return Location("").apply {
            this.latitude = latitude ?: 55.751244
            this.longitude = longitude ?: 37.618423
        }
    }

    private fun mockNearbyUser(currentLocation: Location, gender: String): MapUser {
        val names = if (gender == "female") listOf("Анна", "Мария", "Юлия", "Наташа") else listOf("Дмитрий", "Алексей", "Кирилл", "Иван")
        val beaconOptions = listOf(
            "☕" to "Ищу с кем выпить кофе",
            "🚶" to "Просто гуляю",
            "🌸" to "Гуляю по парку",
            "🎸" to "Хочу живую музыку"
        )
        val distance = 15.0 + Random.nextDouble(5.0)
        val bearing = Random.nextDouble(360.0)
        val targetCoords = calculateOffset(currentLocation.latitude, currentLocation.longitude, distance, bearing)
        val targetLocation = Location("").apply {
            latitude = targetCoords.first
            longitude = targetCoords.second
        }
        val rel = latLonToRel(currentLocation, targetLocation)

        return MapUser(
            userId = "match_${System.currentTimeMillis()}",
            name = names.random(),
            age = 20 + Random.nextInt(10),
            gender = gender,
            beaconEmoji = beaconOptions.random().first,
            beaconText = beaconOptions.random().second,
            distanceMeters = distance,
            batteryLevel = 20 + Random.nextInt(80),
            relX = rel.first,
            relY = rel.second
        )
    }

    private fun mockPhotoPins(): List<MapPhoto> {
        return listOf(
            MapPhoto(
                id = "photo_1",
                userId = "user_1",
                ownerName = "Анна",
                caption = "Барсик у окна",
                imageRes = com.gohavefun.app.R.drawable.cute_cat,
                distanceMeters = 18.0,
                relX = 0.25f,
                relY = 0.28f
            ),
            MapPhoto(
                id = "photo_2",
                userId = "user_2",
                ownerName = "Алексей",
                caption = "Мурка на балконе",
                imageRes = com.gohavefun.app.R.drawable.cute_cat,
                distanceMeters = 22.0,
                relX = 0.72f,
                relY = 0.35f
            ),
            MapPhoto(
                id = "photo_3",
                userId = "user_3",
                ownerName = "Юлия",
                caption = "Рыжик на прогулке",
                imageRes = com.gohavefun.app.R.drawable.cute_cat,
                distanceMeters = 16.0,
                relX = 0.55f,
                relY = 0.65f
            )
        )
    }

    private fun calculateOffset(
        latitude: Double,
        longitude: Double,
        distanceMeters: Double,
        bearingDegrees: Double
    ): Pair<Double, Double> {
        val radius = 6_371_000.0
        val angularDistance = distanceMeters / radius
        val bearing = Math.toRadians(bearingDegrees)
        val latRad = Math.toRadians(latitude)
        val lonRad = Math.toRadians(longitude)

        val newLat = asin(
            sin(latRad) * cos(angularDistance) +
                cos(latRad) * sin(angularDistance) * cos(bearing)
        )
        val newLon = lonRad + atan2(
            sin(bearing) * sin(angularDistance) * cos(latRad),
            cos(angularDistance) - sin(latRad) * sin(newLat)
        )

        return Pair(Math.toDegrees(newLat), Math.toDegrees(newLon))
    }

    private fun latLonToRel(current: Location, target: Location): Pair<Float, Float> {
        val latDiff = target.latitude - current.latitude
        val lonDiff = target.longitude - current.longitude
        val maxDegrees = 0.0003
        val x = ((0.5 + (lonDiff / maxDegrees) * 0.5).coerceIn(0.12, 0.88)).toFloat()
        val y = ((0.5 - (latDiff / maxDegrees) * 0.5).coerceIn(0.12, 0.88)).toFloat()
        return Pair(x, y)
    }
}
