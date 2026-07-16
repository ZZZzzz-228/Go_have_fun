import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../shared/widgets/liquid_glass.dart';
import '../widgets/profile_photo_grid.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/beacon_selector.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock данные
  final String _name = 'Алекс';
  final int _age = 24;
  final String _bio = 'Люблю кофе, велопрогулки и случайные встречи 🚴';
  final bool _isSearchActive = false;
  final DateTime _joinedAt = DateTime(2024, 3, 15);
  final int _meetingsCount = 12;
  final int _chatsCount = 47;

  String? _selectedBeaconEmoji;
  String? _selectedBeaconText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppGradientBackground(
        child: CustomScrollView(
          slivers: [
            // ===== App Bar =====
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () => context.go(RouteNames.editProfile),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () => _showSettings(),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Имя и статус =====
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_name, $_age',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'С нами с ${TimeUtils.formatJoinDate(_joinedAt)}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Переключатель поиска
                        _SearchToggle(
                          isActive: _isSearchActive,
                          onToggle: () => _toggleSearch(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ===== Биография =====
                    if (_bio.isNotEmpty) ...[
                      LiquidGlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          _bio,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ===== Маяк-статус =====
                    BeaconSelector(
                      selectedEmoji: _selectedBeaconEmoji,
                      selectedText: _selectedBeaconText,
                      onSelected: (emoji, text) {
                        setState(() {
                          _selectedBeaconEmoji = emoji;
                          _selectedBeaconText = text;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // ===== Статистика =====
                    const Text(
                      'Моя статистика',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ProfileStatCard(
                            icon: '🤝',
                            label: 'Встреч',
                            value: '$_meetingsCount',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ProfileStatCard(
                            icon: '💬',
                            label: 'Чатов',
                            value: '$_chatsCount',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ProfileStatCard(
                            icon: '📅',
                            label: 'Дней с нами',
                            value:
                            '${DateTime.now().difference(_joinedAt).inDays}',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ===== Переход к паре =====
                    _buildCoupleSection(),

                    const SizedBox(height: 24),

                    // ===== Фото =====
                    const Text(
                      'Мои фото',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const ProfilePhotoGrid(photoUrls: []),

                    const SizedBox(height: 32),

                    // ===== Опасная зона =====
                    _buildDangerZone(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Фон с градиентом
        Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        ),
        // Аватар
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 48)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoupleSection() {
    return GestureDetector(
      onTap: () => context.go(RouteNames.couple),
      child: LiquidGlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(16),
        tint: AppColors.coupleGold,
        showGlow: true,
        child: const Row(
          children: [
            Text('💑', style: TextStyle(fontSize: 32)),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Штамп в паспорте',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Найди свою пару и отмечайте дни вместе',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Зона опасности',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: _showDeleteAccount,
          child: const Text('Удалить аккаунт'),
        ),
      ],
    );
  }

  void _toggleSearch() {
    // TODO: обновить в Firebase
    setState(() {});
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: LiquidGlassCard(
          borderRadius: 28,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _SettingsTile(
                icon: Icons.logout,
                label: 'Выйти',
                onTap: () {
                  Navigator.pop(context);
                  context.go(RouteNames.login);
                },
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Уведомления',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.shield_outlined,
                label: 'Конфиденциальность',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Удалить аккаунт?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Все данные будут безвозвратно удалены. Действие нельзя отменить.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              context.go(RouteNames.login);
            },
            child: const Text('Удалить'),
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
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.success.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.success
                : Colors.white.withValues(alpha: 0.14),
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
            const SizedBox(width: 6),
            Text(
              isActive ? 'В поиске' : 'Offline',
              style: TextStyle(
                color: isActive ? AppColors.success : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
