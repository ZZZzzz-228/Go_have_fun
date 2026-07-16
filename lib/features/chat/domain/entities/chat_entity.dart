import 'package:equatable/equatable.dart';

enum ChatStatus { active, expired, extended }

class ChatEntity extends Equatable {
  final String id;
  final String user1Id;
  final String user2Id;
  final String user1Name;
  final String user2Name;
  final String? user1Avatar;
  final String? user2Avatar;
  final DateTime createdAt;
  final DateTime expiresAt;
  final ChatStatus status;
  final bool user1WantsExtend;
  final bool user2WantsExtend;
  final String? icebreaker;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const ChatEntity({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.user1Name,
    required this.user2Name,
    this.user1Avatar,
    this.user2Avatar,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.user1WantsExtend = false,
    this.user2WantsExtend = false,
    this.icebreaker,
    this.lastMessage,
    this.lastMessageAt,
  });

  /// Секунд до истечения
  int get secondsRemaining {
    final now = DateTime.now();
    final diff = expiresAt.difference(now);
    return diff.isNegative ? 0 : diff.inSeconds;
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => status == ChatStatus.active && !isExpired;

  /// Оба хотят продлить?
  bool get bothWantExtend => user1WantsExtend && user2WantsExtend;

  @override
  List<Object?> get props => [
        id,
        user1Id,
        user2Id,
        user1Name,
        user2Name,
        user1Avatar,
        user2Avatar,
        createdAt,
        expiresAt,
        status,
        user1WantsExtend,
        user2WantsExtend,
        icebreaker,
        lastMessage,
        lastMessageAt,
      ];

  ChatEntity copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    String? user1Name,
    String? user2Name,
    String? user1Avatar,
    String? user2Avatar,
    DateTime? createdAt,
    DateTime? expiresAt,
    ChatStatus? status,
    bool? user1WantsExtend,
    bool? user2WantsExtend,
    String? icebreaker,
    String? lastMessage,
    DateTime? lastMessageAt,
  }) =>
      ChatEntity(
        id: id ?? this.id,
        user1Id: user1Id ?? this.user1Id,
        user2Id: user2Id ?? this.user2Id,
        user1Name: user1Name ?? this.user1Name,
        user2Name: user2Name ?? this.user2Name,
        user1Avatar: user1Avatar ?? this.user1Avatar,
        user2Avatar: user2Avatar ?? this.user2Avatar,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt ?? this.expiresAt,
        status: status ?? this.status,
        user1WantsExtend: user1WantsExtend ?? this.user1WantsExtend,
        user2WantsExtend: user2WantsExtend ?? this.user2WantsExtend,
        icebreaker: icebreaker ?? this.icebreaker,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      );
}

class MessageEntity extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool isRead;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.isRead = false,
  });

  @override
  List<Object?> get props =>
      [id, chatId, senderId, text, sentAt, isRead];
}
