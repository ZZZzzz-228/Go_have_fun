import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Вкладка «Друзья» — список друзей.
/// TODO: подключить реальный список друзей из Firestore, когда появится модель дружбы.
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Друзья',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      body: const _EmptyState(
        emoji: '🧑‍🤝‍🧑',
        title: 'Пока никого нет',
        subtitle:
            'Когда вы познакомитесь на карте и захотите остаться на связи —\nдрузья появятся здесь.',
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
