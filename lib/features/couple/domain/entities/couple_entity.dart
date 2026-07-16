import 'package:equatable/equatable.dart';

class CoupleEntity extends Equatable {
  final String id;
  final String user1Id;
  final String user2Id;
  final String user1Name;
  final String user2Name;
  final String? user1Avatar;
  final String? user2Avatar;
  final DateTime startedAt;
  final bool isActive;

  const CoupleEntity({
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

  Duration get duration => DateTime.now().difference(startedAt);

  int get daysTogeher => duration.inDays;

  @override
  List<Object?> get props => [
        id,
        user1Id,
        user2Id,
        user1Name,
        user2Name,
        user1Avatar,
        user2Avatar,
        startedAt,
        isActive,
      ];
}
