import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/chat_visibility_provider.dart';
import '../../../../shared/widgets/app_ui.dart';
import '../../domain/entities/location_entity.dart';
import '../providers/map_provider.dart';
import '../widgets/beacon_status_sheet.dart';
import '../widgets/map_user_marker.dart';
import '../widgets/user_profile_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  String? _lastPreviewedUserId;
  bool _isPreviewSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _maybeShowMatchPreview(mapState);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          _buildMap(context, mapState, isDark),
          _buildTopBar(context, mapState, isDark),
          _buildRightButtons(mapState),
          _buildHourglass(mapState),
          // Панель "Поиск активен" удалена — управление через песочные часы
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
          Positioned(
            bottom: 202,
            left: 16,
            right: 16,
            child: _buildMainButton(mapState),
          ),
          Positioned(
            bottom: 138,
            left: 16,
            right: 16,
            child: Align(
              alignment: Alignment.centerRight,
              child: AppMapFab(
                icon: Icons.my_location_rounded,
                gradient: true,
                tooltip: 'Моё местоположение',
                onTap: _centerOnMe,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context, MapState mapState, bool isDark) {
    final center = mapState.myLocation ?? const LatLng(55.7558, 37.6173);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 16.5,
        minZoom: 12,
        maxZoom: 19,
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        onTap: (_, __) {},
      ),
      children: [
        if (isDark) ...[
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/dark_matter_nolabels/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.gohavefun.app',
            retinaMode: RetinaMode.isHighDensity(context),
          ),
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/dark_matter_only_labels/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.gohavefun.app',
            retinaMode: RetinaMode.isHighDensity(context),
          ),
        ] else
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.gohavefun.app',
            retinaMode: RetinaMode.isHighDensity(context),
          ),
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
        MarkerLayer(
          markers: mapState.safeZones.map((zone) {
            return Marker(
              point: LatLng(zone.latitude, zone.longitude),
              width: 34,
              height: 34,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBg(context),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.safeZone, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(zone.emoji, style: const TextStyle(fontSize: 15)),
                ),
              ),
            );
          }).toList(),
        ),
        MarkerLayer(
          markers: [
            if (mapState.myLocation != null)
              Marker(
                point: mapState.myLocation!,
                width: 60,
                height: 60,
                child: _MyLocationMarker(pulseController: _pulseController),
              ),
            ...mapState.nearbyUsers.map(
              (user) => Marker(
                point: user.latLng,
                width: 90,
                height: 90,
                alignment: Alignment.bottomCenter,
                child: MapUserMarker(
                  user: user,
                  onTap: () => _onUserTapped(user),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, MapState mapState, bool isDark) {
    final street = mapState.streetName;
    final temp = mapState.temperatureC;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;

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
              bgColor.withValues(alpha: 0.95),
              bgColor.withValues(alpha: 0.0),
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
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: Text(
                    street ??
                        (mapState.isLocatingStreet
                            ? 'определяем улицу…'
                            : 'локация недоступна'),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  temp != null
                      ? '${mapState.weatherEmoji} ${temp.round()}°C'
                      : '${mapState.weatherEmoji} …',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textMuted(context),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightButtons(MapState mapState) {
    return Positioned(
      top: 56,
      right: 16,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppMapFab(
              icon: Icons.wifi_tethering_rounded,
              onTap: _showBeaconSheet,
              tooltip: 'Мой статус',
            ),
            const SizedBox(height: 12),
            // Паника доступна только во время активного поиска (гуляй)
            if (mapState.isSearchActive)
              AppMapFab(
                icon: Icons.warning_amber_rounded,
                color: AppColors.error.withValues(alpha: 0.15),
                onTap: _onPanic,
                tooltip: 'Кнопка паники',
              ),
            if (!mapState.isSearchActive) const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  // В левом верхнем углу — вращающиеся песочные часы с оставшимся временем
  Widget _buildHourglass(MapState mapState) {
    if (!mapState.isSearchActive) return const SizedBox.shrink();

    // Размещаем часы ниже заголовка, чтобы не закрывать улицу/погоду
    return Positioned(
      top: 120,
      left: 16,
      child: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () {
            // По тапу выключаем поиск
            ref.read(mapProvider.notifier).stopSearchSession();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Поиск остановлен')),
            );
          },
          child: Tooltip(
            message: 'Нажми, чтобы остановить поиск',
            child: _HourglassTimer(seconds: mapState.searchSecondsRemaining),
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton(MapState mapState) {
    if (mapState.isSearchActive) return const SizedBox.shrink();

    return AppButton(
      label: 'Гулять',
      emoji: '🚶',
      onTap: () => _startSearch(mapState),
    );
  }

  void _centerOnMe() {
    final loc = ref.read(mapProvider).myLocation;
    if (loc != null) {
      _mapController.move(loc, 16.5);
    }
  }

  void _startSearch(MapState mapState) {
    ref.read(mapProvider.notifier).startSearchSession();
  }

  void _maybeShowMatchPreview(MapState mapState) {
    if (!mapState.isSearchActive || mapState.isPanicMode) return;
    if (mapState.nearbyUsers.isEmpty || _isPreviewSheetOpen) return;
    final candidate = mapState.nearbyUsers.first;
    if (candidate.userId == _lastPreviewedUserId) return;

    _lastPreviewedUserId = candidate.userId;
    ref.read(mapProvider.notifier).acceptMatch(candidate.userId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showUserPreviewSheet(candidate);
    });
  }

  void _showUserPreviewSheet(MapUserEntity user) {
    if (_isPreviewSheetOpen) return;
    _isPreviewSheetOpen = true;
    final mapState = ref.read(mapProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => UserProfileSheet(
        user: user,
        myLocation: mapState.myLocation,
        onMessage: () => _startChat(user),
        onMatch: () => _startChat(user),
        onSkip: () => _skipMatch(user),
      ),
    ).whenComplete(() {
      if (mounted) {
        _isPreviewSheetOpen = false;
      }
    });
  }

  void _onUserTapped(MapUserEntity user) {
    ref.read(mapProvider.notifier).acceptMatch(user.userId);
    _showUserPreviewSheet(user);
  }

  void _skipMatch(MapUserEntity user) {
    if (!mounted) return;
    Navigator.pop(context);
    ref.read(mapProvider.notifier).skipMatch(user.userId);
    setState(() {
      _lastPreviewedUserId = null;
    });
  }

  void _startChat(MapUserEntity user) {
    ref.read(chatVisibilityProvider.notifier).state = true;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    final chatId = const Uuid().v4();
    context.go('${RouteNames.chat}/$chatId');
  }

  void _showBeaconSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BeaconStatusSheet(
        onSelected: (emoji, text) {
          ref.read(mapProvider.notifier).setBeacon(emoji, text);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _activatePanic() async {
    if (!mounted) return;
    ref.read(chatVisibilityProvider.notifier).state = false;
    ref.read(mapProvider.notifier).activatePanic();

    final countryCode = ref.read(mapProvider).countryCode;
    final emergencyNumber = countryCode == 'RU' ? '112' : '911';

    // Перейти явно на экран карты, чтобы избежать возможного черного экрана
    try {
      if (mounted) context.go(RouteNames.map);
    } catch (_) {}

    // Небольшая пауза, чтобы завершились анимации/оверлеи
    await Future.delayed(const Duration(milliseconds: 300));
    // Покажем пользователю диалог с предложением перейти в телефон
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Экстренный вызов', style: Theme.of(ctx).textTheme.headlineSmall),
        content: Text(
          'Мы скрыли тебя с карты и завершили чаты. Перейти в телефон, чтобы вызвать службу $emergencyNumber?',
          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted(ctx)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.canPop(ctx)) Navigator.pop(ctx);
            },
            child: Text('Отмена', style: TextStyle(color: AppColors.textMuted(ctx))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              if (Navigator.canPop(ctx)) Navigator.pop(ctx);
              try {
                final launchUri = Uri(scheme: 'tel', path: emergencyNumber);
                if (await canLaunchUrl(launchUri)) {
                  await launchUrl(launchUri, mode: LaunchMode.externalApplication);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Не удалось открыть телефонный набор для $emergencyNumber'), backgroundColor: AppColors.error),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка при попытке перейти в телефон: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Перейти в телефон'),
          ),
        ],
      ),
    );
  }

  void _onPanic() {
    // Защита: паника работает только если пользователь сейчас в режиме "Гуляй"
    if (!ref.read(mapProvider).isSearchActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Кнопка паники доступна только во время прогулки'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '🚨 Кнопка паники',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          'Ты исчезнешь с карты для всех, завершишь все активные чаты и перейдёшь к экстренному звонку. Продолжить?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted(context),
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(color: AppColors.textMuted(context)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _activatePanic();
            },
            child: const Text('Активировать'),
          ),
        ],
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

// Вращающиеся песочные часы с оставшимся временем (мин:сек)
class _HourglassTimer extends StatefulWidget {
  final int seconds;
  const _HourglassTimer({required this.seconds});

  @override
  State<_HourglassTimer> createState() => _HourglassTimerState();
}

class _HourglassTimerState extends State<_HourglassTimer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _format(int s) {
    final mm = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_top, size: 16, color: AppColors.textMuted(context)),
              const SizedBox(height: 2),
              Text(_format(widget.seconds),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
            ],
          ),
        ),
      ),
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
      child: MapOverlayPanel(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.edit_outlined,
              size: 14,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }
}
