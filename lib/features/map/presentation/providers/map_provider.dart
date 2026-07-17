import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/location_entity.dart';

/// Погода по коду Open-Meteo (WMO weather code) -> эмодзи
String weatherEmojiFromCode(int code) {
  if (code == 0) return '☀️';
  if (code == 1 || code == 2) return '🌤️';
  if (code == 3) return '☁️';
  if (code == 45 || code == 48) return '🌫️';
  if (code >= 51 && code <= 57) return '🌦️';
  if (code >= 61 && code <= 67) return '🌧️';
  if (code >= 71 && code <= 77) return '🌨️';
  if (code >= 80 && code <= 82) return '🌦️';
  if (code >= 85 && code <= 86) return '🌨️';
  if (code >= 95) return '⛈️';
  return '⛅';
}

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
  final String currentUserGender;
  final String? activeMatchUserId;
  final Set<String> ignoredMatchUserIds;

  // Улица и погода (авто-определение)
  final String? streetName;
  final double? temperatureC;
  final String weatherEmoji;
  final bool isLocatingStreet;
  final String? countryCode;

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
    this.currentUserGender = 'female',
    this.activeMatchUserId,
    this.ignoredMatchUserIds = const {},
    this.streetName,
    this.temperatureC,
    this.weatherEmoji = '☀️',
    this.isLocatingStreet = false,
    this.countryCode,
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
    String? currentUserGender,
    String? activeMatchUserId,
    Set<String>? ignoredMatchUserIds,
    String? streetName,
    double? temperatureC,
    String? weatherEmoji,
    bool? isLocatingStreet,
    String? countryCode,
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
        currentUserGender: currentUserGender ?? this.currentUserGender,
        activeMatchUserId: activeMatchUserId ?? this.activeMatchUserId,
        ignoredMatchUserIds: ignoredMatchUserIds ?? this.ignoredMatchUserIds,
        streetName: streetName ?? this.streetName,
        temperatureC: temperatureC ?? this.temperatureC,
        weatherEmoji: weatherEmoji ?? this.weatherEmoji,
        isLocatingStreet: isLocatingStreet ?? this.isLocatingStreet,
        countryCode: countryCode ?? this.countryCode,
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
  Timer? _weatherRefreshTimer;
  StreamSubscription<Position>? _positionStream;
  LatLng? _lastGeoFetchLocation;

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

      // Определить улицу и погоду автоматически
      _updateStreetAndWeather(loc);

      // Обновлять погоду каждые 10 минут (время всегда берётся системное — автоматически)
      _weatherRefreshTimer?.cancel();
      _weatherRefreshTimer = Timer.periodic(const Duration(minutes: 10), (_) {
        if (state.myLocation != null) {
          _updateStreetAndWeather(state.myLocation!, forceWeather: true);
        }
      });

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

      // Обновляем улицу/погоду только если сместились заметно (~120м),
      // чтобы не спамить запросы при каждом мелком движении
      if (_lastGeoFetchLocation == null ||
          Geolocator.distanceBetween(
                _lastGeoFetchLocation!.latitude,
                _lastGeoFetchLocation!.longitude,
                loc.latitude,
                loc.longitude,
              ) >
              120) {
        _updateStreetAndWeather(loc);
      }
    });
  }

  /// Автоматически определить название улицы (по гео) и погоду (по времени/координатам)
  Future<void> _updateStreetAndWeather(LatLng loc,
      {bool forceWeather = false}) async {
    _lastGeoFetchLocation = loc;
    state = state.copyWith(isLocatingStreet: true);

    // Улица — обратное геокодирование
    try {
      final placemarks =
          await placemarkFromCoordinates(loc.latitude, loc.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final street = (p.thoroughfare != null && p.thoroughfare!.isNotEmpty)
            ? p.thoroughfare!
            : (p.street ?? p.subLocality ?? p.locality ?? 'Твоё местоположение');
        final rawCountry = p.isoCountryCode ?? p.country;
        final normalizedCountry = rawCountry?.toUpperCase();
        final countryCode = normalizedCountry != null &&
                (normalizedCountry.contains('RUSS') || normalizedCountry.contains('РОСС'))
            ? 'RU'
            : p.isoCountryCode?.toUpperCase();
        if (mounted) {
          state = state.copyWith(
            streetName: street,
            isLocatingStreet: false,
            countryCode: countryCode,
          );
        }
      } else if (mounted) {
        state = state.copyWith(isLocatingStreet: false);
      }
    } catch (_) {
      if (mounted) state = state.copyWith(isLocatingStreet: false);
    }

    // Погода — Open-Meteo, без ключа, по текущим координатам
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${loc.latitude}&longitude=${loc.longitude}'
        '&current_weather=true',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final current = data['current_weather'] as Map<String, dynamic>?;
        if (current != null) {
          final temp = (current['temperature'] as num).toDouble();
          final code = (current['weathercode'] as num).toInt();
          state = state.copyWith(
            temperatureC: temp,
            weatherEmoji: weatherEmojiFromCode(code),
          );
        }
      }
    } catch (_) {
      // тихо игнорируем — погода необязательна для работы карты
    }
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

  void setCurrentUserGender(String gender) {
    state = state.copyWith(currentUserGender: gender);
  }

  void acceptMatch(String userId) {
    state = state.copyWith(activeMatchUserId: userId);
  }

  void skipMatch(String userId) {
    state = state.copyWith(
      ignoredMatchUserIds: {...state.ignoredMatchUserIds, userId},
    );
  }

  static List<MapUserEntity> filterVisibleUsers({
    required List<MapUserEntity> users,
    required String currentUserGender,
    String? activeMatchUserId,
    required Set<String> ignoredMatchUserIds,
  }) {
    final filteredByGender = users.where((user) {
      if (ignoredMatchUserIds.contains(user.userId)) return false;
      if (activeMatchUserId != null) return user.userId == activeMatchUserId;
      if (currentUserGender == 'male') return user.gender == 'female';
      if (currentUserGender == 'female') return user.gender == 'male';
      return true;
    }).toList();

    return filteredByGender.isEmpty ? [] : [filteredByGender.first];
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

    final rnd = Random();
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
        batteryLevel: 15 + rnd.nextInt(85),
        headingDegrees: rnd.nextDouble() * 360,
      ));
    }
    return MapNotifier.filterVisibleUsers(
      users: users,
      currentUserGender: state.currentUserGender,
      activeMatchUserId: state.activeMatchUserId,
      ignoredMatchUserIds: state.ignoredMatchUserIds,
    );
  }

  List<SafeZone> _generateMockSafeZones(LatLng center) {
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
    _weatherRefreshTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }
}
