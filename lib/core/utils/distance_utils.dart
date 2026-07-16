import 'dart:math';
import 'package:latlong2/latlong.dart';

class DistanceUtils {
  DistanceUtils._();

  static const Distance _distance = Distance();

  /// Расстояние в метрах между двумя точками
  static double metersBetween(LatLng a, LatLng b) {
    return _distance.as(LengthUnit.Meter, a, b);
  }

  /// Смещение координат для анти-сталкинга
  /// Добавляет случайное смещение до [maxMeters] метров
  static LatLng fuzzCoordinates(LatLng original, {double maxMeters = 50.0}) {
    final random = Random();
    // Перевод метров в градусы (приближение)
    final latOffset = (random.nextDouble() - 0.5) * 2 * maxMeters / 111320;
    final lonOffset = (random.nextDouble() - 0.5) * 2 * maxMeters /
        (111320 * cos(original.latitude * pi / 180));
    return LatLng(
      original.latitude + latOffset,
      original.longitude + lonOffset,
    );
  }

  /// Проверка, находится ли точка в радиусе
  static bool isWithinRadius(LatLng center, LatLng point, double radiusM) {
    return metersBetween(center, point) <= radiusM;
  }

  /// Форматирование расстояния для отображения
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} м';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} км';
    }
  }
}
