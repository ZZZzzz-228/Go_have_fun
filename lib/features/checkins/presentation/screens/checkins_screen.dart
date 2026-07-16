import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Вкладка «Чекины» — места, где ты отмечался.
/// TODO: подключить реальные чекины (safe zones), когда появится их сохранение по пользователю.
class CheckinsScreen extends StatelessWidget {
  const CheckinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Чекины',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('📍', style: TextStyle(fontSize: 56)),
              SizedBox(height: 16),
              Text(
                'Чекинов пока нет',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Отмечайся в безопасных местах на карте — кофейнях,\nбарах и парках — и они появятся тут.',
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
