import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/location_entity.dart';

// ===== Вспомогательные типы =====

class SafeZone {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String emoji;
  const SafeZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.emoji,
  });
}

// ===== Состояние карты =====

class MapState {
  final LatLng? myLocation;
  final List<MapUserEntity> nearbyUsers;
  final List<SafeZone> safeZones;
  final bool isSearchActive;
  final int searchSecondsRemaining;
  final String? currentBeaconEmoji;
  final String? currentBeaconText;
  final bool isPanicMode;
  final bool isLoading;
  final String? error;

  const MapState({
    this.myLocation,
    this.nearbyUsers = const [],
    this.safeZones = const [],
    this.isSearchActive = false,
    this.searchSecondsRemaining = AppConstants.searchSessionDuration,
    this.currentBeaconEmoji,
    this.currentBeaconText,
    this.isPanicMode = false,
    this.isLoading = false,
    this.error,
  });

  MapState copyWith({
    LatLng? myLocation,
    List<MapUserEntity>? nearbyUsers,
    List<SafeZone>? safeZones,
    bool? isSearchActive,
    int? searchSecondsRemaining,
    String? currentBeaconEmoji,
    String? currentBeaconText,
    bool? isPanicMode,
    bool? isLoading,
    String? error,
  }) =>
      MapState(
        myLocation: myLocation ?? this.myLocation,
        nearbyUsers: nearbyUsers ?? this.nearbyUsers,
        safeZones: safeZones ?? this.safeZones,
        isSearchActive: isSearchActive ?? this.isSearchActive,
        searchSecondsRemaining:
            searchSecondsRemaining ?? this.searchSecondsRemaining,
        currentBeaconEmoji: currentBeaconEmoji ?? this.currentBeaconEmoji,
        currentBeaconText: currentBeaconText ?? this.currentBeaconText,
        isPanicMode: isPanicMode ?? this.isPanicMode,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}

// ===== Провайдер =====

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(const MapState());

  Timer? _locationTimer;
  Timer? _searchTimer;
  StreamSubscription<Position>? _positionStream;

  /// Инициализировать геолокацию
  Future<void> initLocation() async {
    state = state.copyWith(isLoading: true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        isLoading: false,
        error: 'Включи геолокацию на устройстве',
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          isLoading: false,
          error: 'Нужен доступ к геолокации',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        isLoading: false,
        error: 'Разреши доступ к локации в настройках',
      );
      return;
    }

    // Получить текущую позицию
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final loc = LatLng(pos.latitude, pos.longitude);
      state = state.copyWith(
        myLocation: loc,
        isLoading: false,
        safeZones: _generateMockSafeZones(loc),
        nearbyUsers: _generateMockUsers(loc),
      );

      // Запустить слежение
      _startLocationTracking();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка получения локации: $e',
      );
    }
  }

  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // обновлять каждые 10 метров
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((pos) {
      if (!mounted) return;
      final loc = LatLng(pos.latitude, pos.longitude);
      state = state.copyWith(
        myLocation: loc,
        nearbyUsers: _generateMockUsers(loc), // в реальном — из Firestore
      );
    });
  }

  /// Начать сессию поиска (2 часа)
  void startSearchSession() {
    state = state.copyWith(
      isSearchActive: true,
      searchSecondsRemaining: AppConstants.searchSessionDuration,
    );

    _searchTimer?.cancel();
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final remaining = state.searchSecondsRemaining - 1;
      if (remaining <= 0) {
        t.cancel();
        stopSearchSession();
      } else {
        state = state.copyWith(searchSecondsRemaining: remaining);
      }
    });
  }

  /// Остановить поиск
  void stopSearchSession() {
    _searchTimer?.cancel();
    state = state.copyWith(
      isSearchActive: false,
      searchSecondsRemaining: AppConstants.searchSessionDuration,
      nearbyUsers: [], // убрать с карты
    );
  }

  /// Установить маяк-статус
  void setBeacon(String emoji, String text) {
    state = state.copyWith(
      currentBeaconEmoji: emoji,
      currentBeaconText: text,
    );
  }

  /// Режим паники — исчезнуть с карты
  void activatePanic() {
    _searchTimer?.cancel();
    _positionStream?.cancel();
    state = state.copyWith(
      isPanicMode: true,
      isSearchActive: false,
      nearbyUsers: [],
      myLocation: null, // не показывать нашу точку
    );

    // Через 30 секунд восстановить (без видимости другим)
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        state = state.copyWith(isPanicMode: false);
        initLocation();
      }
    });
  }

  // ===== Mock данные для демонстрации =====

  List<MapUserEntity> _generateMockUsers(LatLng center) {
    if (!state.isSearchActive) return [];
    final rnd = Random();
    final users = <MapUserEntity>[];
    const names = [
      'Анна', 'Мария', 'Дмитрий', 'Алексей',
      'Юлия', 'Кирилл', 'Наташа', 'Иван'
    ];
    const genders = ['female', 'female', 'male', 'male'];
    const beacons = [
      ['☕', 'Ищу с кем выпить кофе'],
      ['🚶', 'Просто гуляю'],
      ['🍺', 'Идём в бар'],
      ['🎸', 'На концерт вместе'],
    ];

    final count = 3 + rnd.nextInt(5);
    for (int i = 0; i < count; i++) {
      // Случайное смещение в 100м (анти-сталкинг — дополнительно ещё +50м)
      final latOff = (rnd.nextDouble() - 0.5) * 0.0018;
      final lonOff = (rnd.nextDouble() - 0.5) * 0.0022;
      final beacon = beacons[rnd.nextInt(beacons.length)];
      final gender = genders[rnd.nextInt(genders.length)];

      users.add(MapUserEntity(
        userId: 'mock_$i',
        name: names[rnd.nextInt(names.length)],
        age: 18 + rnd.nextInt(15),
        gender: gender,
        avatarUrl: null,
        beaconEmoji: beacon[0],
        beaconText: beacon[1],
        fuzzedLatitude: center.latitude + latOff,
        fuzzedLongitude: center.longitude + lonOff,
        distanceMeters: 20 + rnd.nextDouble() * 80,
        lastSeen: DateTime.now(),
      ));
    }
    return users;
  }

  List<SafeZone> _generateMockSafeZones(LatLng center) {
    final rnd = Random();
    return [
      SafeZone(
        id: 'sz1',
        name: 'Кофейня «Утро»',
        latitude: center.latitude + 0.001,
        longitude: center.longitude + 0.001,
        emoji: '☕',
      ),
      SafeZone(
        id: 'sz2',
        name: 'Бар «Пятница»',
        latitude: center.latitude - 0.0008,
        longitude: center.longitude + 0.0015,
        emoji: '🍺',
      ),
      SafeZone(
        id: 'sz3',
        name: 'Парк «Центральный»',
        latitude: center.latitude + 0.0006,
        longitude: center.longitude - 0.001,
        emoji: '🌳',
      ),
    ];
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _searchTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }
}
