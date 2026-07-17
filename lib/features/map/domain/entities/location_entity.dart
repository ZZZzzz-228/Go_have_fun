import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class LocationEntity extends Equatable {
  final String userId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime updatedAt;
  final bool isActive;

  const LocationEntity({
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.updatedAt,
    required this.isActive,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  @override
  List<Object?> get props =>
      [userId, latitude, longitude, accuracy, updatedAt, isActive];
}

/// Пользователь на карте с «размытыми» координатами (анти-сталкинг)
class MapUserEntity extends Equatable {
  final String userId;
  final String name;
  final int age;
  final String gender;
  final String? avatarUrl;
  final String? beaconEmoji;
  final String? beaconText;

  /// Размытые координаты для отображения (не точные!)
  final double fuzzedLatitude;
  final double fuzzedLongitude;

  final double distanceMeters;
  final DateTime lastSeen;
  final int? batteryLevel;
  final double? headingDegrees;

  const MapUserEntity({
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    this.avatarUrl,
    this.beaconEmoji,
    this.beaconText,
    required this.fuzzedLatitude,
    required this.fuzzedLongitude,
    required this.distanceMeters,
    required this.lastSeen,
    this.batteryLevel,
    this.headingDegrees,
  });

  LatLng get latLng => LatLng(fuzzedLatitude, fuzzedLongitude);

  String get beaconDisplay =>
      beaconEmoji != null && beaconText != null
          ? '$beaconEmoji $beaconText'
          : '🚶 Гуляю';

  bool get isMale => gender == 'male';
  bool get isFemale => gender == 'female';

  @override
  List<Object?> get props => [
        userId,
        name,
        age,
        gender,
        avatarUrl,
        beaconEmoji,
        beaconText,
        fuzzedLatitude,
        fuzzedLongitude,
        distanceMeters,
        lastSeen,
        batteryLevel,
        headingDegrees,
      ];
}
