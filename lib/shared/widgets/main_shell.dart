import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../providers/chat_visibility_provider.dart';
import 'navbar/navbar_providers.dart';
import 'navbar/navbar_widget.dart';

/// Главная оболочка приложения — навбар из LiquidGlass-NavBar поверх
/// GoRouter ShellRoute. Светлый content-first дизайн.
class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  // ===== Маршрутизация и индексы (с учётом условного чат-таба) =====

  int _indexForLocation(String loc, bool showChats) {
    if (loc.startsWith(RouteNames.couple))   return showChats ? 3 : 2;
    if (loc.startsWith(RouteNames.profile))  return showChats ? 2 : 1;
    if (showChats && loc.startsWith(RouteNames.chatsList)) return 1;
    return 0; // map
  }

  String _routeForIndex(int i, bool showChats) {
    if (i == 0) return RouteNames.map;
    if (i == 1) return showChats ? RouteNames.chatsList : RouteNames.profile;
    if (i == 2) return showChats ? RouteNames.profile : RouteNames.couple;
    return RouteNames.couple;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showChats = ref.watch(chatVisibilityProvider);
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location, showChats);

    // Синхронизируем навбар-стейт с текущим маршрутом
    final navState = ref.watch(navbarStateProvider);
    if (navState.currentIndex != currentIndex &&
        navState.positions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navbarStateProvider.notifier).setCurrentIndex(currentIndex);
      });
    }

    // ===== Список табов =====
    final navItems = <_NavSpec>[
      _NavSpec(
        icon: Icons.location_on_outlined,
        activeIcon: Icons.location_on_rounded,
        label: 'карта',
      ),
      if (showChats)
        _NavSpec(
          icon: Icons.chat_bubble_outline_rounded,
          activeIcon: Icons.chat_bubble_rounded,
          label: 'чаты',
        ),
      _NavSpec(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'ты',
      ),
      _NavSpec(
        icon: Icons.favorite_border_rounded,
        activeIcon: Icons.favorite_rounded,
        label: 'пара',
      ),
    ];

    final icons = navItems
        .map((e) => Icon(_activeIconFor(navItems.indexOf(e), e, currentIndex)))
        .toList();
    final labels = navItems.map((e) => e.label).toList();

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: NavbarWidget(
          icons: icons,
          labels: labels,
          selectedColor: AppColors.primary,
          unselectedColor: AppColors.textSecondary,
          tintColor: AppColors.primary,
          onItemTap: (i) => context.go(_routeForIndex(i, showChats)),
        ),
      ),
    );
  }

  IconData _activeIconFor(int i, _NavSpec spec, int currentIndex) =>
      i == currentIndex ? spec.activeIcon : spec.icon;
}

class _NavSpec {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavSpec({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
