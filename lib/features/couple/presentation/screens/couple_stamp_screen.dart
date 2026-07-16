import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_utils.dart';

class CoupleStampScreen extends StatefulWidget {
  const CoupleStampScreen({super.key});

  @override
  State<CoupleStampScreen> createState() => _CoupleStampScreenState();
}

class _CoupleStampScreenState extends State<CoupleStampScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _stampController;
  late Animation<double> _stampScale;
  late Animation<double> _stampRotation;
  late Animation<double> _stampOpacity;

  final DateTime _startedAt = DateTime(2024, 11, 3);
  bool _stamped = false;

  @override
  void initState() {
    super.initState();
    _stampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _stampScale = Tween<double>(begin: 3.0, end: 1.0).animate(
      CurvedAnimation(parent: _stampController, curve: Curves.easeOutBack),
    );
    _stampRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _stampController, curve: Curves.easeOut),
    );
    _stampOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _stampController, curve: Curves.easeIn),
    );

    // Анимация штампа через секунду
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _stampController.forward();
        HapticFeedback.heavyImpact();
        setState(() => _stamped = true);
      }
    });
  }

  @override
  void dispose() {
    _stampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1208), // Цвет старого паспорта
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white70),
          onPressed: () => context.go(RouteNames.couple),
        ),
        title: const Text(
          'Цифровой штамп',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Страница паспорта
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EDD0), // Цвет паспортной страницы
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Заголовок страницы
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PassportLine(),
                        const SizedBox(width: 8),
                        const Text(
                          'СВИДЕТЕЛЬСТВО',
                          style: TextStyle(
                            color: Color(0xFF4A3728),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _PassportLine(),
                      ],
                    ),
                    const Text(
                      'об отношениях',
                      style: TextStyle(
                        color: Color(0xFF7A6050),
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Имена
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _PassportPerson(name: 'Алекс'),
                        const Text(
                          '&',
                          style: TextStyle(
                            color: Color(0xFF4A3728),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        _PassportPerson(name: 'Маша'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Разделитель
                    Row(
                      children: List.generate(
                        40,
                            (_) => Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFB0956A).withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Штамп
                    AnimatedBuilder(
                      animation: _stampController,
                      builder: (_, child) {
                        if (!_stamped) return const SizedBox(height: 120);
                        return Opacity(
                          opacity: _stampOpacity.value,
                          child: Transform.rotate(
                            angle: _stampRotation.value,
                            child: Transform.scale(
                              scale: _stampScale.value,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: _buildStamp(),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: List.generate(
                        40,
                            (_) => Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFB0956A).withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Дата
                    Text(
                      'с ${TimeUtils.formatJoinDate(_startedAt)}',
                      style: const TextStyle(
                        color: Color(0xFF7A6050),
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      TimeUtils.coupleAge(_startedAt),
                      style: const TextStyle(
                        color: Color(0xFF4A3728),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Подпись
                    const Text(
                      'Go Have Fun',
                      style: TextStyle(
                        color: Color(0xFF7A6050),
                        fontSize: 10,
                        letterSpacing: 2,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Поделиться
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('📤 Делимся штампом!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share_outlined,
                          color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Поделиться штампом',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStamp() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFCC2244),
          width: 4,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('❤️', style: TextStyle(fontSize: 28)),
          const Text(
            'ВМЕСТЕ',
            style: TextStyle(
              color: Color(0xFFCC2244),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          Text(
            TimeUtils.coupleAge(_startedAt),
            style: const TextStyle(
              color: Color(0xFFCC2244),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PassportLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1,
        color: const Color(0xFFB0956A).withValues(alpha: 0.5),
      ),
    );
  }
}

class _PassportPerson extends StatelessWidget {
  final String name;
  const _PassportPerson({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFB0956A),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text('👤', style: TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            color: Color(0xFF4A3728),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
