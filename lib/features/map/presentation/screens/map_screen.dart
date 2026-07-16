import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_utils.dart';
import '../providers/map_provider.dart';
import '../widgets/beacon_status_sheet.dart';
import '../widgets/map_user_marker.dart';
import '../widgets/search_timer_widget.dart';
import '../widgets/safe_zone_info_widget.dart';

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

    // Инициализировать локацию
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
          // ===== КАРТА =====
          _buildMap(mapState),

          // ===== Топ-бар =====
          _buildTopBar(mapState),

          // ===== Таймер поиска =====
          if (mapState.isSearchActive)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: SearchTimerWidget(
                remainingSeconds: mapState.searchSecondsRemaining,
                onStop: () =>
                    ref.read(mapProvider.notifier).stopSearchSession(),
              ),
            ),

          // ===== Подсказка если не время =====
          if (!TimeUtils.isActiveSearchTime() && !mapState.isSearchActive)
            _buildNotActiveTimeOverlay(),

          // ===== Кнопки снизу =====
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Кнопка паники
                _PanicButton(
                  onTap: () => _onPanic(),
                ),
                const SizedBox(height: 12),

                // Кнопка "Найти меня"
                FloatingActionButton.small(
                  heroTag: 'locate',
                  backgroundColor: AppColors.surface,
                  onPressed: _centerOnMe,
                  child: const Icon(Icons.my_location,
                      color: AppColors.primary),
                ),
                const SizedBox(height: 12),

                // Главная кнопка — Начать поиск
                _buildMainButton(mapState),
              ],
            ),
          ),

          // ===== Маяк-статус =====
          if (mapState.currentBeaconText != null)
            Positioned(
              bottom: 160,
              left: 16,
              right: 80,
              child: _BeaconBadge(
                emoji: mapState.currentBeaconEmoji ?? '🚶',
                text: mapState.currentBeaconText!,
                onTap: _showBeaconSheet,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap(MapState mapState) {
    final center = mapState.myLocation ?? const LatLng(55.7558, 37.6173);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 16.5,
        minZoom: 12,
        maxZoom: 19,
        backgroundColor: const Color(0xFF1A1A2E),
        onTap: (_, __) {},
      ),
      children: [
        // Тайлы карты (тёмная тема)
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.gohavefun.app',
        ),

        // Heatmap пользователей (зоны скопления, анти-сталкинг)
        CircleLayer(
          circles: mapState.nearbyUsers.map((u) {
            return CircleMarker(
              point: u.latLng,
              radius: 40,
              color: AppColors.mapHeatMid,
              borderColor: AppColors.primary.withOpacity(0.3),
              borderStrokeWidth: 1,
              useRadiusInMeter: false,
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
                width: 56,
                height: 56,
                child: MapUserMarker(
                  user: user,
                  onTap: () => _onUserTapped(user.userId, user.name),
                ),
              ),
            ),
          ],
        ),

        // Безопасные зоны (заведения-партнёры)
        MarkerLayer(
          markers: mapState.safeZones.map((zone) {
            return Marker(
              point: LatLng(zone.latitude, zone.longitude),
              width: 36,
              height: 36,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.safeZone,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.safeZone.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('☕', style: TextStyle(fontSize: 16)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTopBar(MapState mapState) {
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
              AppColors.background,
              AppColors.background.withOpacity(0),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Онлайн-статус
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${mapState.nearbyUsers.length} рядом',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Статус-маяк кнопка
                GestureDetector(
                  onTap: _showBeaconSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('📡', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 4),
                        Text(
                          'Статус',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton(MapState mapState) {
    if (mapState.isSearchActive) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _startSearch(mapState),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.45),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '🔍 Начать поиск',
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

  Widget _buildNotActiveTimeOverlay() {
    final timeLeft = TimeUtils.timeUntilActiveSearch();
    return Positioned(
      bottom: 160,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surfaceVariant,
          ),
        ),
        child: Row(
          children: [
            const Text('🌙', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Поиск включается в 19:00',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Осталось ${TimeUtils.formatDuration(timeLeft)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    if (!TimeUtils.isActiveSearchTime()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Поиск работает с 19:00 до 00:00'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    ref.read(mapProvider.notifier).startSearchSession();
  }

  void _onUserTapped(String userId, String userName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _UserContactSheet(
        userId: userId,
        userName: userName,
        onConnect: () {
          Navigator.pop(context);
          final chatId = const Uuid().v4();
          context.go('${RouteNames.chat}/$chatId');
        },
      ),
    );
  }

  void _showBeaconSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BeaconStatusSheet(
        onSelected: (emoji, text) {
          ref.read(mapProvider.notifier).setBeacon(emoji, text);
          Navigator.pop(context);
        },
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
                  color: AppColors.primary.withOpacity(0.15 * (1 - pulseController.value)),
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
                    color: AppColors.primary.withOpacity(0.5),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.edit_outlined,
                size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _PanicButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PanicButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFD32F2F),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Text('🆘', style: TextStyle(fontSize: 22)),
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
              color: AppColors.surfaceVariant,
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
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
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
          GestureDetector(
            onTap: onConnect,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '💬 Начать чат с $userName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
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
