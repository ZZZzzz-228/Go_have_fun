import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavbarState {
  final int currentIndex;
  final double draggablePosition;
  final double dragOffset;
  final List<double> positions;

  const NavbarState({
    required this.currentIndex,
    required this.draggablePosition,
    required this.dragOffset,
    required this.positions,
  });

  NavbarState copyWith({
    int? currentIndex,
    double? draggablePosition,
    double? dragOffset,
    List<double>? positions,
  }) {
    return NavbarState(
      currentIndex: currentIndex ?? this.currentIndex,
      draggablePosition: draggablePosition ?? this.draggablePosition,
      dragOffset: dragOffset ?? this.dragOffset,
      positions: positions ?? this.positions,
    );
  }
}

class NavbarStateNotifier extends StateNotifier<NavbarState> {
  NavbarStateNotifier()
      : super(
    const NavbarState(
      currentIndex: 0,
      draggablePosition: 0,
      dragOffset: 0,
      positions: [],
    ),
  );

  void initPositions({
    required int itemCount,
    required double containerWidth,
  }) {
    if (state.positions.isNotEmpty) return;

    final itemWidth = containerWidth / itemCount;
    final positions = List<double>.generate(
      itemCount,
          (i) => itemWidth * i + itemWidth / 2,
    );

    state = state.copyWith(
      positions: positions,
      draggablePosition: positions[state.currentIndex],
    );
  }

  void initMeasuredPositions(List<GlobalKey> iconKeys) {
    final positions = iconKeys.map((key) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        return box.localToGlobal(Offset.zero).dx + box.size.width / 2;
      }
      return 0.0;
    }).toList();

    if (positions.isEmpty || positions.first == 0.0) return;

    state = state.copyWith(
      positions: positions,
      draggablePosition: positions[state.currentIndex],
    );
  }

  void setCurrentIndex(int index) {
    if (index < 0 || index >= state.positions.length) return;

    state = state.copyWith(
      currentIndex: index,
      draggablePosition: state.positions[index],
    );
  }

  void setDraggablePosition(double pos) {
    state = state.copyWith(draggablePosition: pos);
  }

  void setDragOffset(double off) {
    state = state.copyWith(dragOffset: off);
  }
}

final navbarStateProvider =
StateNotifierProvider<NavbarStateNotifier, NavbarState>(
      (ref) => NavbarStateNotifier(),
);
