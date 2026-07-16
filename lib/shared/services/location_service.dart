import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_constants.dart';

/// Сервис геолокации с анти-сталкинг защитой
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  StreamSubscription<Position>? _subscription;
  LatLng? _currentLocation;
  final _locationController = StreamController<LatLng>.broadcast();

  Stream<LatLng> get locationStream => _locationController.stream;
  LatLng? get currentLocation => _currentLocation;

  /// Запросить разрешения и начать отслеживание
  Future<bool> requestPermissionsAndStart() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    await startTracking();
    return true;
  }

  /// Начать отслеживание позиции
  Future<void> startTracking() async {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _subscription = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) {
      _currentLocation = LatLng(pos.latitude, pos.longitude);
      _locationController.add(_currentLocation!);
    });
  }

  /// Получить текущую позицию
  Future<LatLng?> getCurrentPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentLocation = LatLng(pos.latitude, pos.longitude);
      return _currentLocation;
    } catch (_) {
      return null;
    }
  }

  /// Размытые координаты для защиты от сталкинга
  /// Добавляет случайное смещение до 50 метров
  LatLng fuzzLocation(LatLng original) {
    final rnd = Random();
    final maxMeters = AppConstants.coordinateFuzzMeters;
    final latOffset = (rnd.nextDouble() - 0.5) * 2 * maxMeters / 111320;
    final lonOffset = (rnd.nextDouble() - 0.5) * 2 * maxMeters /
        (111320 * cos(original.latitude * pi / 180));
    return LatLng(
      original.latitude + latOffset,
      original.longitude + lonOffset,
    );
  }

  /// Расстояние в метрах
  double distanceTo(LatLng other) {
    if (_currentLocation == null) return double.infinity;
    return const Distance().as(LengthUnit.Meter, _currentLocation!, other);
  }

  /// Остановить отслеживание
  Future<void> stopTracking() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> dispose() async {
    await stopTracking();
    await _locationController.close();
  }
}
