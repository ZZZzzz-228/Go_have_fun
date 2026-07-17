class AppConstants {
  AppConstants._();

  // Приложение
  static const String appName = 'Go Have Fun';
  static const String appVersion = '1.0.0';

  // Радиусы обнаружения (в метрах)
  static const double discoveryRadiusMeters = 100.0;
  static const double heatmapRadiusMeters = 200.0;

  // Время чата (в секундах)
  static const int chatDurationSeconds = 15 * 60;       // 15 минут
  static const int chatExtensionSeconds = 5 * 60;       // +5 минут при продлении
  static const int burnZoneSeconds = 3 * 60;            // 3 минуты — зона "горения"
  static const int criticalZoneSeconds = 60;            // 1 минута — критическая зона

  // Таймер поиска (в секундах)
  static const int searchSessionDuration = 2 * 60 * 60; // 2 часа

  // Время активного поиска (работает вечером)
  static const int activeSearchStartHour = 19;  // 19:00
  static const int activeSearchEndHour = 24;    // 00:00

  // Задержка обновления локации (мс)
  static const int locationUpdateIntervalMs = 5000; // 5 секунд

  // Анти-сталкинг: смещение координат (метры)
  static const double coordinateFuzzMeters = 50.0;

  // Исчезновение с карты после окончания чата (мс)
  static const int disappearAfterChatMs = 30000; // 30 секунд

  // Хранение
  static const String prefKeyUserId = 'user_id';
  static const String prefKeyOnboarded = 'is_onboarded';
  static const String prefKeySearchActive = 'search_active';
  static const String prefKeyCoupleId = 'couple_id';

  // Firestore коллекции
  static const String colUsers = 'users';
  static const String colLocations = 'user_locations';
  static const String colChats = 'chats';
  static const String colMessages = 'messages';
  static const String colCouples = 'couples';
  static const String colReports = 'reports';
  static const String colSearchSessions = 'search_sessions';
  static const String colCatPhotos = 'cat_photos';

  static const String prefKeyCatPhotos = 'cat_photos_local';

  // Пагинация
  static const int messagesPageSize = 30;
  static const int usersPageSize = 20;

  // Статусы-маячки
  static const List<Map<String, String>> beaconStatuses = [
    {'emoji': '☕', 'text': 'Ищу с кем выпить кофе'},
    {'emoji': '🍺', 'text': 'Идём в бар'},
    {'emoji': '🚶', 'text': 'Гуляю, присоединяйся'},
    {'emoji': '🎮', 'text': 'Ищу компанию в игру'},
    {'emoji': '🎸', 'text': 'На концерт вместе'},
    {'emoji': '🌆', 'text': 'Исследую город'},
    {'emoji': '🍕', 'text': 'Ищу с кем перекусить'},
    {'emoji': '🐕', 'text': 'Гуляю с собакой'},
  ];

  // Ледоколы — темы для знакомства
  static const List<String> icebreakerTemplates = [
    'Вы оба сейчас в этом месте! Кто найдёт свободную скамейку первым? 🏃',
    'Какой кофе берём? ☕ Угощаешь или вместе пьём?',
    'Назови 3 факта о себе — один из них ложь. Угадаю!',
    'Куда хотел(а) бы попасть прямо сейчас?',
    'Любимое место в этом районе?',
    'Что слушаешь сейчас в наушниках?',
    'Если бы можно было телепортироваться — куда?',
  ];

  // Лимиты
  static const int maxPhotos = 6;
  static const int maxBioLength = 300;
  static const int maxStatusLength = 60;
  static const int minAge = 18;
  static const int maxAge = 60;

  // Безопасность
  static const int maxReportsBeforeReview = 3;
  static const int panicRadius = 500; // скрыть из всех в радиусе (метры)
}
