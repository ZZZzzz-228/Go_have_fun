import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/chat_visibility_provider.dart';
import '../../../../shared/widgets/liquid_glass.dart';
import '../providers/map_provider.dart';
import '../widgets/beacon_status_sheet.dart';
import '../widgets/map_user_marker.dart';
import '../widgets/search_timer_widget.dart';

/// Цвета "шапки" карты — тёмная тема, стеклянные пилюли поверх тёмной карты.
class _MapUI {
  _MapUI._();
  static const Color chipDark = Color(0xFF190B30); // тёмная пилюля-кнопка
  static const Color chipDarkBorder = Color(0x33C9A8FF);
  static const Color subtleText = AppColors.textSecondary;
}

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Инициализировать локацию (гео + улица + погода — всё автоматически)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapProvider.notifier).initLocation();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ===== КАРТА (тёмная, в стиле приложения) =====
          _buildMap(mapState),

          // ===== Шапка: улица + погода =====
          _buildTopBar(mapState),

          // ===== Круглые кнопки справа =====
          _buildRightButtons(mapState),

          // ===== Таймер поиска =====
          if (mapState.isSearchActive)
            Positioned(
              top: 190,
              left: 16,
              right: 16,
              child: SearchTimerWidget(
                remainingSeconds: mapState.searchSecondsRemaining,
                onStop: () =>
                    ref.read(mapProvider.notifier).stopSearchSession(),
              ),
            ),

          // ===== Маяк-статус =====
          if (mapState.currentBeaconText != null)
            Positioned(
              bottom: 264,
              left: 16,
              right: 16,
              child: _BeaconBadge(
                emoji: mapState.currentBeaconEmoji ?? '🚶',
                text: mapState.currentBeaconText!,
                onTap: _showBeaconSheet,
              ),
            ),

          // ===== Главная кнопка «Гулять» — доступна в любое время =====
          Positioned(
            bottom: 202,
            left: 16,
            right: 16,
            child: _buildMainButton(mapState),
          ),

          // ===== Геолокация (над плавающим нижним меню) =====
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: _buildBottomRow(mapState),
          ),
        ],
      ),
    );
  }

  // ===================== КАРТА =====================

  Widget _buildMap(MapState mapState) {
    final center = mapState.myLocation ?? const LatLng(55.7558, 37.6173);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 16.5,
        minZoom: 12,
        maxZoom: 19,
        backgroundColor: AppColors.background,
        onTap: (_, __) {},
      ),
      children: [
        // Тёмные тайлы — в тон общей чёрно-фиолетовой палитре приложения
        TileLayer(
          urlTemplate:
          'https://{s}.basemaps.cartocdn.com/dark_matter_nolabels/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.gohavefun.app',
        ),
        TileLayer(
          urlTemplate:
          'https://{s}.basemaps.cartocdn.com/dark_matter_only_labels/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.gohavefun.app',
        ),

        // Heatmap пользователей (зоны скопления, анти-сталкинг)
        CircleLayer(
          circles: mapState.nearbyUsers.map((u) {
            return CircleMarker(
              point: u.latLng,
              radius: 40,
              color: AppColors.mapHeatMid.withValues(alpha: 0.18),
              borderColor: AppColors.primary.withValues(alpha: 0.25),
              borderStrokeWidth: 1,
              useRadiusInMeter: false,
            );
          }).toList(),
        ),

        // Безопасные зоны (заведения-партнёры)
        MarkerLayer(
          markers: mapState.safeZones.map((zone) {
            return Marker(
              point: LatLng(zone.latitude, zone.longitude),
              width: 34,
              height: 34,
              child: Container(
                decoration: BoxDecoration(
                  color: _MapUI.chipDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.safeZone, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 6),
                  ],
                ),
                child: Center(
                  child:
                  Text(zone.emoji, style: const TextStyle(fontSize: 15)),
                ),
              ),
            );
          }).toList(),
        ),

        // Маркеры пользователей
        MarkerLayer(
          markers: [
            // Моя позиция
            if (mapState.myLocation != null)
              Marker(
                point: mapState.myLocation!,
                width: 60,
                height: 60,
                child: _MyLocationMarker(pulseController: _pulseController),
              ),

            // Другие пользователи (размытые координаты)
            ...mapState.nearbyUsers.map(
                  (user) => Marker(
                point: user.latLng,
                width: 90,
                height: 90,
                alignment: Alignment.bottomCenter,
                child: MapUserMarker(
                  user: user,
                  onTap: () => _onUserTapped(user.userId, user.name),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===================== ШАПКА =====================

  Widget _buildTopBar(MapState mapState) {
    final street = mapState.streetName;
    final temp = mapState.temperatureC;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background.withValues(alpha: 0.95),
              AppColors.background.withValues(alpha: 0.0),
            ],
            stops: const [0.55, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 96, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название улицы — крупно, жирно, с градиентной подсветкой
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: Text(
                    street ??
                        (mapState.isLocatingStreet
                            ? 'определяем улицу…'
                            : 'локация недоступна'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Погода — определяется автоматически по геопозиции
                Row(
                  children: [
                    Text(
                      temp != null
                          ? '${mapState.weatherEmoji} ${temp.round()}°C'
                          : '${mapState.weatherEmoji} …',
                      style: const TextStyle(
                        color: _MapUI.subtleText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== ПРАВЫЕ КРУГЛЫЕ КНОПКИ =====================

  Widget _buildRightButtons(MapState mapState) {
    return Positioned(
      top: 56,
      right: 16,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _CircleIconButton(
              icon: Icons.wifi_tethering_rounded,
              onTap: _showBeaconSheet,
              tooltip: 'Мой статус',
            ),
            const SizedBox(height: 12),
            _CircleIconButton(
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFFF6584),
              onTap: _onPanic,
              tooltip: 'Кнопка паники',
            ),
          ],
        ),
      ),
    );
  }

  // ===================== НИЖНИЙ РЯД =====================

  Widget _buildBottomRow(MapState mapState) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: _centerOnMe,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.45),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.my_location_rounded,
              color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildMainButton(MapState mapState) {
    if (mapState.isSearchActive) {
      return const SizedBox.shrink();
    }

    // «Гулять» доступно в любое время суток — без временных ограничений.
    return GestureDetector(
      onTap: () => _startSearch(mapState),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '🚶 Гулять',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _centerOnMe() {
    final loc = ref.read(mapProvider).myLocation;
    if (loc != null) {
      _mapController.move(loc, 16.5);
    }
  }

  void _startSearch(MapState mapState) {
    // Ограничение по времени (19:00–00:00) убрано по требованию —
    // поиск теперь можно запустить в любой момент.
    ref.read(mapProvider.notifier).startSearchSession();
  }

  void _onUserTapped(String userId, String userName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: LiquidGlassCard(
          borderRadius: 28,
          padding: EdgeInsets.zero,
          showGlow: true,
          child: _UserContactSheet(
            userId: userId,
            userName: userName,
            onConnect: () {
              // Двое "увиделись" — теперь появляется вкладка "Чаты".
              ref.read(chatVisibilityProvider.notifier).state = true;
              Navigator.pop(context);
              final chatId = const Uuid().v4();
              context.go('${RouteNames.chat}/$chatId');
            },
          ),
        ),
      ),
    );
  }

  void _showBeaconSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: LiquidGlassCard(
          borderRadius: 28,
          padding: EdgeInsets.zero,
          child: BeaconStatusSheet(
            onSelected: (emoji, text) {
              ref.read(mapProvider.notifier).setBeacon(emoji, text);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _onPanic() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🚨 Кнопка паники',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Ты исчезнешь с карты для всех и завершишь все активные чаты. Продолжить?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              ref.read(mapProvider.notifier).activatePanic();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔒 Ты в безопасности. Все чаты завершены.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Активировать'),
          ),
        ],
      ),
    );
  }
}

// ===== Вспомогательные виджеты =====

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final String tooltip;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _MapUI.chipDark.withValues(alpha: 0.75),
                shape: BoxShape.circle,
                border: Border.all(color: _MapUI.chipDarkBorder),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              child: Icon(icon, color: iconColor ?? Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class _MyLocationMarker extends StatelessWidget {
  final AnimationController pulseController;

  const _MyLocationMarker({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final scale = 1.0 + pulseController.value * 0.4;
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: scale,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary
                      .withValues(alpha: 0.18 * (1 - pulseController.value)),
                ),
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.5),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BeaconBadge extends StatelessWidget {
  final String emoji;
  final String text;
  final VoidCallback onTap;

  const _BeaconBadge({
    required this.emoji,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _MapUI.chipDark.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.edit_outlined, size: 14, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserContactSheet extends StatelessWidget {
  final String userId;
  final String userName;
  final VoidCallback onConnect;

  const _UserContactSheet({
    required this.userId,
    required this.userName,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Аватар
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.4),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '~50 м от тебя · В поиске',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Row(
              children: [
                Text('⏱️', style: TextStyle(fontSize: 18)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'У тебя будет 15 минут на знакомство. После — пути разойдутся.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LiquidGlassButton(
            label: '💬 Начать чат с $userName',
            onTap: onConnect,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Может в другой раз...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
