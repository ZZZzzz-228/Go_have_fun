class TimeUtils {
  TimeUtils._();

  /// Форматировать секунды в MM:SS
  static String formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Форматировать дни, часы, минуты
  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) return '$days д $hours ч';
    if (hours > 0) return '$hours ч $minutes мин';
    return '$minutes мин';
  }

  /// Проверить, что сейчас активное время поиска (19:00–00:00)
  static bool isActiveSearchTime() {
    final now = DateTime.now();
    final hour = now.hour;
    return hour >= 19 || hour == 0;
  }

  /// Возвращает сколько времени осталось до начала активного времени
  static Duration timeUntilActiveSearch() {
    final now = DateTime.now();
    final activeStart = DateTime(now.year, now.month, now.day, 19, 0);
    if (now.isBefore(activeStart)) {
      return activeStart.difference(now);
    }
    // Следующий день
    final nextDay = DateTime(now.year, now.month, now.day + 1, 19, 0);
    return nextDay.difference(now);
  }

  /// «N мин назад» для статуса локации
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
    if (diff.inHours < 24) return '${diff.inHours} ч назад';
    return '${diff.inDays} д назад';
  }

  /// Красивая дата "с нами с..."
  static String formatJoinDate(DateTime date) {
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Штамп — сколько времени вместе
  static String coupleAge(DateTime since) {
    final now = DateTime.now();
    final diff = now.difference(since);
    final days = diff.inDays;
    final months = days ~/ 30;
    final years = days ~/ 365;

    if (years >= 1) {
      final rem = months - years * 12;
      return '$years г. $rem мес.';
    } else if (months >= 1) {
      final rem = days - months * 30;
      return '$months мес. $rem д.';
    } else {
      return '$days дн.';
    }
  }
}
