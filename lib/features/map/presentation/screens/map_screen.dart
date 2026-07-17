import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../widgets/search_timer_widget.dart';
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          _buildMap(context, mapState, isDark),
          _buildTopBar(context, mapState, isDark),
          _buildRightButtons(mapState),
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
            bottom: 100,
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
            AppMapFab(
              icon: Icons.warning_amber_rounded,
              color: AppColors.error.withValues(alpha: 0.15),
              onTap: _onPanic,
              tooltip: 'Кнопка паники',
            ),
          ],
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

  void _onUserTapped(MapUserEntity user) {
    final mapState = ref.read(mapProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => UserProfileSheet(
        user: user,
        myLocation: mapState.myLocation,
        onMessage: () => _startChat(user.name),
        onMatch: () => _startChat(user.name),
      ),
    );
  }

  void _startChat(String userName) {
    ref.read(chatVisibilityProvider.notifier).state = true;
    Navigator.pop(context);
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

  void _onPanic() {
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
          'Ты исчезнешь с карты для всех и завершишь все активные чаты. Продолжить?',
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
