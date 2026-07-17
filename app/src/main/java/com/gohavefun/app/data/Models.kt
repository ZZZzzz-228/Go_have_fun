package com.gohavefun.app.data

/**
 * Пользователь на карте (с "размытыми" координатами — анти-сталкинг).
 * Перенесено из Flutter (MapUserEntity).
 */
data class MapUser(
    val userId: String,
    val name: String,
    val age: Int,
    val gender: String,           // "male" | "female"
    val beaconEmoji: String?,
    val beaconText: String?,
    val distanceMeters: Double,
    val batteryLevel: Int?,
    // относительная позиция на "карте" (0f..1f), т.к. настоящая карта заменена схематичной
    val relX: Float,
    val relY: Float,
) {
    val isMale get() = gender == "male"
    val isFemale get() = gender == "female"
    val beaconDisplay: String
        get() = if (beaconEmoji != null && beaconText != null) "$beaconEmoji $beaconText" else "🚶 Гуляю"
}

/** Безопасная зона (кофейня/бар/парк). */
data class SafeZone(
    val id: String,
    val name: String,
    val emoji: String,
    val relX: Float,
    val relY: Float,
)

/** Сообщение в чате. */
data class ChatMessage(
    val id: String,
    val senderId: String,   // "me" | "partner"
    val text: String,
    val sentAtMillis: Long,
)
