import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/liquid_glass.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardPage> _pages = [
    _OnboardPage(
      emoji: '📍',
      title: 'Знакомься вживую',
      subtitle:
      'Видь людей на карте в радиусе 100 метров. Реальные встречи, реальные эмоции.',
      color: AppColors.primary,
    ),
    _OnboardPage(
      emoji: '⏱️',
      title: '15 минут — твоё время',
      subtitle:
      'Чат горит. Успей познакомиться, пока таймер не истёк. Адреналин и живость гарантированы.',
      color: AppColors.secondary,
    ),
    _OnboardPage(
      emoji: '🔒',
      title: 'Твоя безопасность',
      subtitle:
      'Точные координаты скрыты. Кнопка паники. Жёсткая модерация. Мы заботимся о тебе.',
      color: AppColors.tertiary,
    ),
    _OnboardPage(
      emoji: '💑',
      title: 'Штамп в паспорте',
      subtitle:
      'Нашёл свою пару — получите совместный штамп. Считайте дни вместе прямо в приложении.',
      color: AppColors.coupleGold,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarded', true);
    if (mounted) context.go(RouteNames.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Пропустить
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: _finish,
                    child: const Text(
                      'Пропустить',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),

              // Страницы
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) {
                    final page = _pages[i];
                    return _OnboardingPage(page: page);
                  },
                ),
              ),

              // Индикаторы
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                      (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == i
                          ? _pages[_currentPage].color
                          : AppColors.surfaceVariant,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Кнопка
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LiquidGlassButton(
                  label: _currentPage < _pages.length - 1
                      ? 'Дальше'
                      : 'Поехали! 🚀',
                  onTap: _nextPage,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardingPage({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LiquidGlassCard(
            borderRadius: 70,
            padding: const EdgeInsets.all(38),
            tint: page.color,
            showGlow: true,
            child: Text(page.emoji, style: const TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
