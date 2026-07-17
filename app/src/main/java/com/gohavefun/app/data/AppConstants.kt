package com.gohavefun.app.data

/**
 * Константы приложения. Перенесено из Flutter (AppConstants).
 */
object AppConstants {
    const val APP_NAME = "Go Have Fun"
    const val APP_VERSION = "1.0.0"

    // Радиусы обнаружения (в метрах)
    const val DISCOVERY_RADIUS_METERS = 100.0

    // Время чата (в секундах)
    const val CHAT_DURATION_SECONDS = 15 * 60        // 15 минут
    const val CHAT_EXTENSION_SECONDS = 5 * 60        // +5 минут при продлении
    const val BURN_ZONE_SECONDS = 3 * 60             // 3 минуты — зона "горения"
    const val CRITICAL_ZONE_SECONDS = 60             // 1 минута — критическая зона

    // Таймер поиска (в секундах)
    const val SEARCH_SESSION_DURATION = 2 * 60 * 60  // 2 часа

    // Лимиты
    const val MAX_BIO_LENGTH = 300
    const val MAX_STATUS_LENGTH = 60
    const val MIN_AGE = 18
    const val MAX_AGE = 60

    // Статусы-маячки
    val beaconStatuses = listOf(
        "☕" to "Ищу с кем выпить кофе",
        "🍺" to "Идём в бар",
        "🚶" to "Гуляю, присоединяйся",
        "🎮" to "Ищу компанию в игру",
        "🎸" to "На концерт вместе",
        "🌆" to "Исследую город",
        "🍕" to "Ищу с кем перекусить",
        "🐕" to "Гуляю с собакой",
    )

    // Ледоколы — темы для знакомства
    val icebreakerTemplates = listOf(
        "Вы оба сейчас в этом месте! Кто найдёт свободную скамейку первым? 🏃",
        "Какой кофе берём? ☕ Угощаешь или вместе пьём?",
        "Назови 3 факта о себе — один из них ложь. Угадаю!",
        "Куда хотел(а) бы попасть прямо сейчас?",
        "Любимое место в этом районе?",
        "Что слушаешь сейчас в наушниках?",
        "Если бы можно было телепортироваться — куда?",
    )
}
