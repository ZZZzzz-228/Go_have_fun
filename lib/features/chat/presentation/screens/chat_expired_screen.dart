import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';

class ChatExpiredScreen extends StatefulWidget {
  const ChatExpiredScreen({super.key});

  @override
  State<ChatExpiredScreen> createState() => _ChatExpiredScreenState();
}

class _ChatExpiredScreenState extends State<ChatExpiredScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Вибрация
    HapticFeedback.heavyImpact();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
          parent: _entryController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeIn),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController.forward();

    // Через 5 секунд вернуться на карту
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) context.go(RouteNames.map);
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge([_entryController, _pulseController]),
        builder: (context, child) {
          return Stack(
            children: [
              // Фоновые угли
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        AppColors.timerRed.withValues(alpha: 0.35 * _fadeAnim.value),
                        AppColors.background,
                      ],
                    ),
                  ),
                ),
              ),

              // Центральный блок
              Center(
                child: Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.scale(
                    scale: _scaleAnim.value,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Огонь
                          Transform.scale(
                            scale: _pulseAnim.value,
                            child: const Text(
                              '🔥',
                              style: TextStyle(fontSize: 96),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Главный текст
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.primaryGradient
                                    .createShader(bounds),
                            child: const Text(
                              'ГУЛЯЙ!',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Время вышло. Этот момент был настоящим 💫',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 17,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Вы больше не видите друг друга на карте',
                            style: TextStyle(
                              color: AppColors.textDisabled,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          // Кнопка
                          GestureDetector(
                            onTap: () => context.go(RouteNames.map),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Ещё раз! 🚀',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
