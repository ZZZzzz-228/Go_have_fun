import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Вкладка «Чаты» — список активных знакомств.
/// TODO: подключить реальный список чатов из Firestore (colChats),
/// когда появится персистентное хранение сессий знакомств.
class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Чаты',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('💬', style: TextStyle(fontSize: 56)),
              SizedBox(height: 16),
              Text(
                'Пока нет активных чатов',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Начни поиск на карте и напиши тому, кто рядом —\nчат появится здесь, пока он "горит".',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
