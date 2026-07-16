import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final int age;
  final String gender; // 'male' | 'female' | 'other'
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
  final int reportCount;

  const UserModel({
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
    this.reportCount = 0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] as String,
      age: (data['age'] as num).toInt(),
      gender: data['gender'] as String,
      bio: data['bio'] as String?,
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      beaconEmoji: data['beaconEmoji'] as String?,
      beaconText: data['beaconText'] as String?,
      isSearchActive: data['isSearchActive'] as bool? ?? false,
      coupleId: data['coupleId'] as String?,
      isInCouple: data['isInCouple'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] as Timestamp).toDate()
          : null,
      isBanned: data['isBanned'] as bool? ?? false,
      reportCount: (data['reportCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'age': age,
        'gender': gender,
        'bio': bio,
        'photoUrls': photoUrls,
        'beaconEmoji': beaconEmoji,
        'beaconText': beaconText,
        'isSearchActive': isSearchActive,
        'coupleId': coupleId,
        'isInCouple': isInCouple,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
        'isBanned': isBanned,
        'reportCount': reportCount,
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        age: age,
        gender: gender,
        bio: bio,
        photoUrls: photoUrls,
        beaconEmoji: beaconEmoji,
        beaconText: beaconText,
        isSearchActive: isSearchActive,
        coupleId: coupleId,
        isInCouple: isInCouple,
        createdAt: createdAt,
        lastSeen: lastSeen,
        isBanned: isBanned,
      );

  UserModel copyWith({
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
    int? reportCount,
  }) =>
      UserModel(
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
        reportCount: reportCount ?? this.reportCount,
      );
}
