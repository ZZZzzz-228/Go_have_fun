import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_ui.dart';

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
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeIn),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController.forward();

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
      backgroundColor: AppColors.scaffoldBg(context),
      body: AnimatedBuilder(
        animation: Listenable.merge([_entryController, _pulseController]),
        builder: (context, child) {
          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        AppColors.timerRed
                            .withValues(alpha: 0.25 * _fadeAnim.value),
                        AppColors.scaffoldBg(context),
                      ],
                    ),
                  ),
                ),
              ),
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
                          Transform.scale(
                            scale: _pulseAnim.value,
                            child: const Text(
                              '🔥',
                              style: TextStyle(fontSize: 88),
                            ),
                          ),
                          const SizedBox(height: 28),
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.primaryGradient.createShader(bounds),
                            child: Text(
                              'ГУЛЯЙ!',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Время вышло. Этот момент был настоящим 💫',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textMuted(context),
                                  height: 1.5,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Вы больше не видите друг друга на карте',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          AppButton(
                            label: 'Ещё раз! 🚀',
                            expanded: false,
                            onTap: () => context.go(RouteNames.map),
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
