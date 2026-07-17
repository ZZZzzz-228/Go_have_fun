import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/burn_timer_header.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/icebreaker_card.dart';
import '../widgets/extend_button.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _shakeAnim = Tween<double>(begin: -4, end: 4)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    // Инициализировать чат
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider(widget.chatId).notifier).initChat(widget.chatId);
    });
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    ref.read(chatProvider(widget.chatId).notifier).sendMessage(text);
    _messageCtrl.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _requestExtend() {
    ref.read(chatProvider(widget.chatId).notifier).requestExtend();
    _shakeController.forward(from: 0);
  }

  void _report() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Пожаловаться',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ReportOption(
                label: '🚫 Неприемлемый контент', onTap: () => _sendReport('content')),
            _ReportOption(
                label: '👹 Фейковый профиль', onTap: () => _sendReport('fake')),
            _ReportOption(
                label: '😨 Угроза безопасности', onTap: () => _sendReport('threat')),
          ],
        ),
      ),
    );
  }

  void _sendReport(String type) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Жалоба отправлена. Мы рассмотрим её в течение часа.'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.chatId));

    // Слушаем истечение времени
    ref.listen(chatProvider(widget.chatId), (prev, next) {
      if (next.isExpired && !(prev?.isExpired ?? false)) {
        _onChatExpired();
      }
      // Вибрация в критической зоне
      if (next.secondsRemaining == AppConstants.criticalZoneSeconds) {
        _shakeController.repeat(reverse: true);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg(context),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Фон — градиент «горения»
          if (chatState.secondsRemaining <= AppConstants.burnZoneSeconds)
            _BurnBackground(
                progress: chatState.secondsRemaining /
                    AppConstants.burnZoneSeconds),

          SafeArea(
            child: Column(
              children: [
                // ===== Горящий таймер =====
                BurnTimerHeader(
                  secondsRemaining: chatState.secondsRemaining,
                  totalSeconds: chatState.totalSeconds,
                  partnerName: chatState.partnerName,
                  onBack: () => context.go(RouteNames.map),
                  onReport: _report,
                ),

                // ===== Ледокол =====
                if (chatState.icebreaker != null && chatState.messages.isEmpty)
                  IcebreakerCard(text: chatState.icebreaker!),

                // ===== Сообщения =====
                Expanded(
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, i) {
                      final msg = chatState.messages[i];
                      return ChatMessageBubble(
                        message: msg.text,
                        isMe: msg.senderId == chatState.myUserId,
                        sentAt: msg.sentAt,
                      );
                    },
                  ),
                ),

                // ===== Кнопка продления =====
                if (chatState.secondsRemaining <=
                    AppConstants.burnZoneSeconds)
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(_shakeAnim.value, 0),
                      child: child,
                    ),
                    child: ExtendButton(
                      myWantsExtend: chatState.myWantsExtend,
                      partnerWantsExtend: chatState.partnerWantsExtend,
                      onExtend: _requestExtend,
                    ),
                  ),

                // ===== Ввод сообщения =====
                _buildInputBar(chatState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ChatState chatState) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderDark
                : AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageCtrl,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMain(context),
                  ),
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Напиши что-нибудь...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted(context),
                    ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurfaceAlt
                    : AppColors.surfaceAlt,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onChatExpired() {
    // Полноэкранная заставка "ГУЛЯЙ"
    context.go(RouteNames.chatExpired);
  }
}

// Фоновое «горение»
class _BurnBackground extends StatelessWidget {
  final double progress; // 0..1, где 0 — конец, 1 — начало зоны горения

  const _BurnBackground({required this.progress});

  @override
  Widget build(BuildContext context) {
    final opacity = (1 - progress) * 0.35;
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.timerRed.withValues(alpha: opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ReportOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
