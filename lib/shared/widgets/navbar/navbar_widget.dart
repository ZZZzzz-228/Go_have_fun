import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'navbar_item_widget.dart';
import 'navbar_draggable_indicator.dart';
import 'navbar_background.dart';
import 'navbar_providers.dart';

/// Внешний тап-бар из LiquidGlass-NavBar, адаптированный под go_router:
/// вместо PageController — колбэк `onItemTap` в main_shell.
class NavbarWidget extends ConsumerStatefulWidget {
  final List<Widget> icons;
  final List<String> labels;
  final double indicatorWidth;
  final double navbarHeight;
  final double bottomPadding;
  final double horizontalPadding;
  final Color selectedColor;
  final Color unselectedColor;
  final Color tintColor;
  final ValueChanged<int> onItemTap;

  const NavbarWidget({
    super.key,
    required this.icons,
    required this.labels,
    required this.onItemTap,
    this.indicatorWidth = 72,
    this.navbarHeight = 64,
    this.bottomPadding = 8,
    this.horizontalPadding = 16,
    this.selectedColor = const Color(0xFF7C3AED),
    this.unselectedColor = const Color(0xFF6B6781),
    this.tintColor = const Color(0xFF7C3AED),
  }) : assert(icons.length == labels.length, 'icons и labels должны совпадать по длине');

  @override
  ConsumerState<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends ConsumerState<NavbarWidget> {
  final List<GlobalKey> _iconKeys = [];

  @override
  void initState() {
    super.initState();
    _iconKeys.addAll(List.generate(widget.icons.length, (_) => GlobalKey()));
  }

  @override
  void didUpdateWidget(covariant NavbarWidget old) {
    super.didUpdateWidget(old);
    if (old.icons.length != widget.icons.length) {
      _iconKeys.clear();
      _iconKeys.addAll(List.generate(widget.icons.length, (_) => GlobalKey()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final navbarState = ref.watch(navbarStateProvider);
    final notifier = ref.read(navbarStateProvider.notifier);

    final screenWidth = 1.sw;
    final itemCount = widget.icons.length;

    // ВАЖНО: провайдер нельзя модифицировать во время build().
    // Поэтому и быстрая аппроксимация, и точное измерение GlobalKey
    // выполняются после завершения построения кадра (post-frame callback).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Быстрая аппроксимация позиций.
      notifier.initPositions(
        itemCount: itemCount,
        containerWidth: screenWidth,
      );
      // Точное измерение через GlobalKey.
      notifier.initMeasuredPositions(_iconKeys);
    });

    final positions = navbarState.positions;
    final currentIndex = navbarState.currentIndex;
    final dragCenter = navbarState.draggablePosition;

    return SizedBox(
      width: screenWidth,
      height: widget.navbarHeight.h + widget.bottomPadding.h,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          // Glass-фон на всю ширину экрана
          Positioned(
            left: 0,
            right: 0,
            bottom: widget.bottomPadding.h,
            child: Padding(
              padding:
              EdgeInsets.symmetric(horizontal: widget.horizontalPadding.w),
              child: NavbarBackground(
                width: screenWidth,
                height: widget.navbarHeight.h,
                tint: widget.tintColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(itemCount, (i) {
                    return NavbarItemWidget(
                      key: _iconKeys[i],
                      icon: widget.icons[i],
                      label: widget.labels[i],
                      isSelected: i == currentIndex,
                      selectedColor: widget.selectedColor,
                      unselectedColor: widget.unselectedColor,
                      onTap: () {
                        notifier.setCurrentIndex(i);
                        widget.onItemTap(i);
                      },
                    );
                  }),
                ),
              ),
            ),
          ),

          // Драг-индикатор
          if (positions.isNotEmpty)
            NavbarDraggableIndicator(
              position: dragCenter,
              baseSize: widget.indicatorWidth,
              itemCount: itemCount,
              snapPositions: positions,
              onDragUpdate: notifier.setDraggablePosition,
              onDragEnd: (i) {
                notifier.setCurrentIndex(i);
                widget.onItemTap(i);
              },
              bottomOffset: widget.bottomPadding.h,
              tint: widget.tintColor,
            ),
        ],
      ),
    );
  }
}
