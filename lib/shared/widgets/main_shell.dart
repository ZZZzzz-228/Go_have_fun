import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import 'app_bottom_nav.dart';

/// Оболочка приложения: контент + компактная нижняя навигация (3 таба).
class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _indexForLocation(String loc) {
    if (loc.startsWith(RouteNames.couple)) return 1;
    if (loc.startsWith(RouteNames.profile)) return 2;
    return 0;
  }

  String _routeForIndex(int i) {
    switch (i) {
      case 1:
        return RouteNames.couple;
      case 2:
        return RouteNames.profile;
      default:
        return RouteNames.map;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);
    final isMap = currentIndex == 0;

    return Scaffold(
      extendBody: true,
      backgroundColor: isMap ? Colors.transparent : AppColors.scaffoldBg(context),
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 4),
        child: AppBottomNav(
          currentIndex: currentIndex,
          onTap: (i) => context.go(_routeForIndex(i)),
        ),
      ),
    );
  }
}
