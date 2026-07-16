import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/couple_entity.dart';

class CoupleModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final String user1Name;
  final String user2Name;
  final String? user1Avatar;
  final String? user2Avatar;
  final DateTime startedAt;
  final bool isActive;

  const CoupleModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.user1Name,
    required this.user2Name,
    this.user1Avatar,
    this.user2Avatar,
    required this.startedAt,
    this.isActive = true,
  });

  factory CoupleModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CoupleModel(
      id: doc.id,
      user1Id: d['user1Id'] as String,
      user2Id: d['user2Id'] as String,
      user1Name: d['user1Name'] as String,
      user2Name: d['user2Name'] as String,
      user1Avatar: d['user1Avatar'] as String?,
      user2Avatar: d['user2Avatar'] as String?,
      startedAt: (d['startedAt'] as Timestamp).toDate(),
      isActive: d['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'user1Id': user1Id,
        'user2Id': user2Id,
        'user1Name': user1Name,
        'user2Name': user2Name,
        'user1Avatar': user1Avatar,
        'user2Avatar': user2Avatar,
        'startedAt': Timestamp.fromDate(startedAt),
        'isActive': isActive,
      };

  CoupleEntity toEntity() => CoupleEntity(
        id: id,
        user1Id: user1Id,
        user2Id: user2Id,
        user1Name: user1Name,
        user2Name: user2Name,
        user1Avatar: user1Avatar,
        user2Avatar: user2Avatar,
        startedAt: startedAt,
        isActive: isActive,
      );
}
