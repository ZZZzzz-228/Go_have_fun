import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_entity.dart';

class ChatModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final String user1Name;
  final String user2Name;
  final String? user1Avatar;
  final String? user2Avatar;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String status; // 'active' | 'expired' | 'extended'
  final bool user1WantsExtend;
  final bool user2WantsExtend;
  final String? icebreaker;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const ChatModel({
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

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      user1Id: d['user1Id'] as String,
      user2Id: d['user2Id'] as String,
      user1Name: d['user1Name'] as String,
      user2Name: d['user2Name'] as String,
      user1Avatar: d['user1Avatar'] as String?,
      user2Avatar: d['user2Avatar'] as String?,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      expiresAt: (d['expiresAt'] as Timestamp).toDate(),
      status: d['status'] as String? ?? 'active',
      user1WantsExtend: d['user1WantsExtend'] as bool? ?? false,
      user2WantsExtend: d['user2WantsExtend'] as bool? ?? false,
      icebreaker: d['icebreaker'] as String?,
      lastMessage: d['lastMessage'] as String?,
      lastMessageAt: d['lastMessageAt'] != null
          ? (d['lastMessageAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'user1Id': user1Id,
        'user2Id': user2Id,
        'user1Name': user1Name,
        'user2Name': user2Name,
        'user1Avatar': user1Avatar,
        'user2Avatar': user2Avatar,
        'createdAt': Timestamp.fromDate(createdAt),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'status': status,
        'user1WantsExtend': user1WantsExtend,
        'user2WantsExtend': user2WantsExtend,
        'icebreaker': icebreaker,
        'lastMessage': lastMessage,
        'lastMessageAt':
            lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      };

  ChatEntity toEntity() => ChatEntity(
        id: id,
        user1Id: user1Id,
        user2Id: user2Id,
        user1Name: user1Name,
        user2Name: user2Name,
        user1Avatar: user1Avatar,
        user2Avatar: user2Avatar,
        createdAt: createdAt,
        expiresAt: expiresAt,
        status: _parseStatus(status),
        user1WantsExtend: user1WantsExtend,
        user2WantsExtend: user2WantsExtend,
        icebreaker: icebreaker,
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt,
      );

  static ChatStatus _parseStatus(String s) {
    switch (s) {
      case 'extended':
        return ChatStatus.extended;
      case 'expired':
        return ChatStatus.expired;
      default:
        return ChatStatus.active;
    }
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.isRead = false,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      chatId: d['chatId'] as String,
      senderId: d['senderId'] as String,
      text: d['text'] as String,
      sentAt: (d['sentAt'] as Timestamp).toDate(),
      isRead: d['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'chatId': chatId,
        'senderId': senderId,
        'text': text,
        'sentAt': Timestamp.fromDate(sentAt),
        'isRead': isRead,
      };

  MessageEntity toEntity() => MessageEntity(
        id: id,
        chatId: chatId,
        senderId: senderId,
        text: text,
        sentAt: sentAt,
        isRead: isRead,
      );
}
