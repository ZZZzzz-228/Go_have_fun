import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/chat_entity.dart';

// ===== Мок-сообщение =====
class MockMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  const MockMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });
}

// ===== Состояние чата =====
class ChatState {
  final String chatId;
  final String myUserId;
  final String partnerName;
  final int secondsRemaining;
  final int totalSeconds;
  final List<MockMessage> messages;
  final bool myWantsExtend;
  final bool partnerWantsExtend;
  final String? icebreaker;
  final bool isExpired;

  const ChatState({
    required this.chatId,
    this.myUserId = 'me',
    this.partnerName = 'Аня',
    required this.secondsRemaining,
    this.totalSeconds = AppConstants.chatDurationSeconds,
    this.messages = const [],
    this.myWantsExtend = false,
    this.partnerWantsExtend = false,
    this.icebreaker,
    this.isExpired = false,
  });

  ChatState copyWith({
    String? chatId,
    String? myUserId,
    String? partnerName,
    int? secondsRemaining,
    int? totalSeconds,
    List<MockMessage>? messages,
    bool? myWantsExtend,
    bool? partnerWantsExtend,
    String? icebreaker,
    bool? isExpired,
  }) =>
      ChatState(
        chatId: chatId ?? this.chatId,
        myUserId: myUserId ?? this.myUserId,
        partnerName: partnerName ?? this.partnerName,
        secondsRemaining: secondsRemaining ?? this.secondsRemaining,
        totalSeconds: totalSeconds ?? this.totalSeconds,
        messages: messages ?? this.messages,
        myWantsExtend: myWantsExtend ?? this.myWantsExtend,
        partnerWantsExtend: partnerWantsExtend ?? this.partnerWantsExtend,
        icebreaker: icebreaker ?? this.icebreaker,
        isExpired: isExpired ?? this.isExpired,
      );
}

// ===== Провайдер =====
final chatProvider =
    StateNotifierProviderFamily<ChatNotifier, ChatState, String>(
  (ref, chatId) => ChatNotifier(chatId),
);

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(String chatId)
      : super(ChatState(
          chatId: chatId,
          secondsRemaining: AppConstants.chatDurationSeconds,
        ));

  Timer? _timer;

  void initChat(String chatId) {
    // Выбрать случайный ледокол
    final icebreakers = AppConstants.icebreakerTemplates;
    final icebreaker = icebreakers[Random().nextInt(icebreakers.length)];

    state = state.copyWith(
      chatId: chatId,
      icebreaker: icebreaker,
      secondsRemaining: AppConstants.chatDurationSeconds,
    );

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final remaining = state.secondsRemaining - 1;
      if (remaining <= 0) {
        t.cancel();
        state = state.copyWith(secondsRemaining: 0, isExpired: true);
      } else {
        state = state.copyWith(secondsRemaining: remaining);
      }
    });
  }

  void sendMessage(String text) {
    if (state.isExpired) return;
    final msg = MockMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'me',
      text: text,
      sentAt: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, msg]);

    // Симуляция ответа партнёра
    Future.delayed(Duration(seconds: 1 + Random().nextInt(3)), () {
      if (!mounted || state.isExpired) return;
      final replies = [
        'Хаха, интересно 😄',
        'О, серьёзно?',
        'Мне тоже нравится!',
        'Давай встретимся в кофейне!',
        'Окей, иду 👋',
        'Где именно ты находишься?',
        '🔥',
      ];
      final reply = MockMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'partner',
        text: replies[Random().nextInt(replies.length)],
        sentAt: DateTime.now(),
      );
      state = state.copyWith(messages: [...state.messages, reply]);
    });
  }

  void requestExtend() {
    state = state.copyWith(myWantsExtend: true);

    // Симуляция согласия партнёра (50% вероятность)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final agrees = Random().nextBool();
      if (agrees) {
        state = state.copyWith(
          partnerWantsExtend: true,
          secondsRemaining:
              state.secondsRemaining + AppConstants.chatExtensionSeconds,
          totalSeconds:
              state.totalSeconds + AppConstants.chatExtensionSeconds,
          myWantsExtend: false,
          partnerWantsExtend: false,
        );
        _startTimer(); // Перезапустить таймер
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
