import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../widgets/beacon_selector.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final String _name = 'Алекс';
  final int _age = 24;
  final bool _isSearchActive = false;
  final DateTime _joinedAt = DateTime(2024, 3, 15);
  final int _meetingsCount = 12;
  final int _chatsCount = 47;

  String? _selectedBeaconLabel;

  @override
  Widget build(BuildContext context) {
    final initials = _name.isEmpty ? 'A' : _name[0].toUpperCase();
    final days =
        DateTime.now().difference(_joinedAt).inDays;
    final bottomNavPadding = MediaQuery.paddingOf(context).bottom + 170;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg(context),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, bottomNavPadding),
          children: [
            // ===== App Bar =====
            Row(
              children: [
                Text(
                  'Профиль',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  tooltip: 'Настройки',
                  onPressed: _showSettingsSheet,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Редактировать',
                  onPressed: () => context.go(RouteNames.editProfile),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ===== Аватар без фото =====
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.20),
                      blurRadius: 24,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== Имя + статус-онлайн =====
            Center(
              child: Column(
                children: [
                  Text(
                    '$_name, $_age',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'С нами с ${TimeUtils.formatJoinDate(_joinedAt)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SearchToggle(
                    isActive: _isSearchActive,
                    onToggle: () => setState(() {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ===== Статус-маяк (без эмодзи, иконки) =====
            BeaconSelector(
              selectedLabel: _selectedBeaconLabel,
              onSelected: (label) =>
                  setState(() => _selectedBeaconLabel = label),
            ),
            const SizedBox(height: 24),

            // ===== Статистика =====
            Text(
              'Статистика',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.handshake_rounded,
                    color: AppColors.primary,
                    value: '$_meetingsCount',
                    label: 'Встреч',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.chat_bubble_rounded,
                    color: AppColors.secondary,
                    value: '$_chatsCount',
                    label: 'Чатов',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_month_rounded,
                    color: AppColors.info,
                    value: '$days',
                    label: 'Дней',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ===== Штамп пары =====
            _CoupleCard(
              onTap: () => context.go(RouteNames.couple),
            ),
            const SizedBox(height: 24),

            // ===== Опасная зона =====
            Text(
              'Аккаунт',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _SettingsRow(
              icon: Icons.notifications_active_outlined,
              label: 'Уведомления',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.lock_outline_rounded,
              label: 'Конфиденциальность',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.help_outline_rounded,
              label: 'Поддержка',
              onTap: () {},
            ),
            const SizedBox(height: 20),
            _SettingsRow(
              icon: Icons.logout_rounded,
              label: 'Выйти',
              color: AppColors.error,
              onTap: () => context.go(RouteNames.login),
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              icon: Icons.delete_outline_rounded,
              label: 'Удалить аккаунт',
              color: AppColors.error,
              onTap: _confirmDelete,
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet() {
    final themeMode = ref.read(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg(context),
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Настройки',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _ModernCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Тёмная тема',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    Switch.adaptive(
                      value: isDark,
                      activeTrackColor: AppColors.primary,
                      onChanged: (_) {
                        ref.read(themeModeProvider.notifier).toggle();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _SettingsRow(
                icon: Icons.tune_rounded,
                label: 'Основные',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              _SettingsRow(
                icon: Icons.shield_outlined,
                label: 'Безопасность',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              _SettingsRow(
                icon: Icons.info_outline,
                label: 'О приложении',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить аккаунт?'),
        content: const Text(
          'Все данные будут безвозвратно удалены. Действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(RouteNames.login);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Внутренние виджеты — минималистичные, content-first
// =====================================================================

class _ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? tint;

  const _ModernCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Material(
      color: AppColors.cardBg(context),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
            color: tint ?? AppColors.cardBg(context),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return _ModernCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CoupleCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CoupleCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      tint: AppColors.coupleGold.withValues(alpha: 0.06),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.coupleGold, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.diversity_3_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Штамп в паспорте',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  'Найди свою пару и отмечайте дни вместе',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return _ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: c, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: c,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _SearchToggle extends StatelessWidget {
  final bool isActive;
  final VoidCallback onToggle;

  const _SearchToggle({required this.isActive, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.success.withValues(alpha: 0.12)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive ? AppColors.success : AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.success : AppColors.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isActive ? 'В поиске' : 'Невидимый',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isActive
                      ? AppColors.success
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
