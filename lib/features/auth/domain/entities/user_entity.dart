import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String? bio;
  final List<String> photoUrls;
  final String? beaconEmoji;
  final String? beaconText;
  final bool isSearchActive;
  final String? coupleId;
  final bool isInCouple;
  final DateTime createdAt;
  final DateTime? lastSeen;
  final bool isBanned;

  const UserEntity({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    this.bio,
    required this.photoUrls,
    this.beaconEmoji,
    this.beaconText,
    required this.isSearchActive,
    this.coupleId,
    required this.isInCouple,
    required this.createdAt,
    this.lastSeen,
    this.isBanned = false,
  });

  String get displayName => name;

  String? get avatarUrl => photoUrls.isNotEmpty ? photoUrls.first : null;

  String get beaconDisplay =>
      beaconEmoji != null && beaconText != null
          ? '$beaconEmoji $beaconText'
          : '🚶 Гуляю';

  bool get hasBeacon => beaconEmoji != null;

  bool get isMale => gender == 'male';
  bool get isFemale => gender == 'female';

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        gender,
        bio,
        photoUrls,
        beaconEmoji,
        beaconText,
        isSearchActive,
        coupleId,
        isInCouple,
        createdAt,
        lastSeen,
        isBanned,
      ];

  UserEntity copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? bio,
    List<String>? photoUrls,
    String? beaconEmoji,
    String? beaconText,
    bool? isSearchActive,
    String? coupleId,
    bool? isInCouple,
    DateTime? createdAt,
    DateTime? lastSeen,
    bool? isBanned,
  }) =>
      UserEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        bio: bio ?? this.bio,
        photoUrls: photoUrls ?? this.photoUrls,
        beaconEmoji: beaconEmoji ?? this.beaconEmoji,
        beaconText: beaconText ?? this.beaconText,
        isSearchActive: isSearchActive ?? this.isSearchActive,
        coupleId: coupleId ?? this.coupleId,
        isInCouple: isInCouple ?? this.isInCouple,
        createdAt: createdAt ?? this.createdAt,
        lastSeen: lastSeen ?? this.lastSeen,
        isBanned: isBanned ?? this.isBanned,
      );
}
