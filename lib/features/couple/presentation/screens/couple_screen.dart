import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_utils.dart';

class CoupleScreen extends StatefulWidget {
  const CoupleScreen({super.key});

  @override
  State<CoupleScreen> createState() => _CoupleScreenState();
}

class _CoupleScreenState extends State<CoupleScreen>
    with TickerProviderStateMixin {
  // Mock: нет пары
  final bool _hasCouple = false;

  // Mock: есть пара
  // final bool _hasCouple = true;
  final String _partnerName = 'Маша';
  final String? _partnerAvatar = null;
  final DateTime _startedAt = DateTime(2024, 11, 3);

  late AnimationController _heartController;
  late Animation<double> _heartAnim;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _heartAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('💑 Ваша пара'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go(RouteNames.profile),
        ),
      ),
      body: _hasCouple ? _buildCoupleView() : _buildNoCoupleView(),
    );
  }

  Widget _buildNoCoupleView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _heartAnim,
              builder: (_, __) => Transform.scale(
                scale: _heartAnim.value,
                child: const Text('💔', style: TextStyle(fontSize: 80)),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Ты пока один',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Выйди на прогулку и найди свою пару.\nКогда ты подружишься с кем-то в живую — предложи быть парой.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => context.go(RouteNames.map),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  '🚶 Идти гулять',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoupleView() {
    final duration = DateTime.now().difference(_startedAt);
    final ageStr = TimeUtils.coupleAge(_startedAt);

    return SingleChildScrollView(
      child: Column(
        children: [
          // ===== Штамп =====
          _buildStamp(ageStr),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Статистика
                _buildCoupleStats(duration),
                const SizedBox(height: 24),

                // Кнопка перейти к штампу
                GestureDetector(
                  onTap: () => context.go(RouteNames.coupleStamp),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Text('🪪', style: TextStyle(fontSize: 28)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Цифровой штамп',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Покажи партнёру',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Разорвать пару
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _showBreakupDialog,
                  icon: const Icon(Icons.heart_broken_outlined),
                  label: const Text('Завершить отношения'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStamp(String ageStr) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.coupleGold.withOpacity(0.12),
            AppColors.couplePink.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.coupleGold.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.coupleGold.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '💑 ВМЕСТЕ',
            style: TextStyle(
              color: AppColors.coupleGold,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PersonAvatar(name: 'Алекс', avatar: null),
              AnimatedBuilder(
                animation: _heartAnim,
                builder: (_, __) => Transform.scale(
                  scale: _heartAnim.value,
                  child: const Text('❤️',
                      style: TextStyle(fontSize: 32)),
                ),
              ),
              _PersonAvatar(name: _partnerName, avatar: _partnerAvatar),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ageStr,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'с ${TimeUtils.formatJoinDate(_startedAt)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoupleStats(Duration duration) {
    return Row(
      children: [
        Expanded(
          child: _CoupleStatCard(
            icon: '📅',
            label: 'Дней вместе',
            value: '${duration.inDays}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CoupleStatCard(
            icon: '⌛',
            label: 'Часов вместе',
            value: '${duration.inHours}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CoupleStatCard(
            icon: '💬',
            label: 'Встреч в GHF',
            value: '3',
          ),
        ),
      ],
    );
  }

  void _showBreakupDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('💔 Завершить отношения?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Штамп пропадёт, и ты снова сможешь знакомиться. Это нельзя отменить.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Не сейчас',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              // TODO: удалить пару из Firebase
            },
            child: const Text('Завершить'),
          ),
        ],
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  final String name;
  final String? avatar;

  const _PersonAvatar({required this.name, this.avatar});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            border: Border.all(color: AppColors.coupleGold, width: 2),
          ),
          child: avatar != null
              ? ClipOval(child: Image.network(avatar!, fit: BoxFit.cover))
              : const Center(
                  child: Text('👤', style: TextStyle(fontSize: 30))),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CoupleStatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _CoupleStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
