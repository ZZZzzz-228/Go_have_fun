import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_ui.dart';
import '../../../map/presentation/providers/map_provider.dart';
import '../../domain/entities/cat_photo_entity.dart';
import '../providers/cats_provider.dart';
import '../widgets/cat_marker.dart';
import '../widgets/cat_photo_sheet.dart';

class CatsMapScreen extends ConsumerStatefulWidget {
  const CatsMapScreen({super.key});

  @override
  ConsumerState<CatsMapScreen> createState() => _CatsMapScreenState();
}

class _CatsMapScreenState extends ConsumerState<CatsMapScreen> {
  final MapController _mapController = MapController();
  final ImagePicker _picker = ImagePicker();
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(mapProvider.notifier).initLocation();
      _seedIfNeeded();
    });
  }

  void _seedIfNeeded() {
    final location = ref.read(mapProvider).myLocation;
    if (location != null) {
      ref.read(catsProvider.notifier).seedMockPhotos(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final catsState = ref.watch(catsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<MapState>(mapProvider, (prev, next) {
      if (next.myLocation != null && prev?.myLocation == null) {
        ref.read(catsProvider.notifier).seedMockPhotos(next.myLocation!);
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          _buildMap(context, mapState, catsState, isDark),
          _buildTopBar(context, isDark),
          Positioned(
            bottom: 170,
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
          Positioned(
            bottom: 112,
            left: 16,
            child: AppMapFab(
              icon: Icons.camera_alt_rounded,
              gradient: true,
              tooltip: 'Сфотографировать кота',
              onTap: _captureCat,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(
    BuildContext context,
    MapState mapState,
    CatsState catsState,
    bool isDark,
  ) {
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
        MarkerLayer(
          markers: catsState.photos
              .map(
                (photo) => Marker(
                  point: photo.latLng,
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  child: CatMarker(
                    photo: photo,
                    onTap: () => _showPhoto(photo),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: Text(
                    '🐱 Котики',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Листай карту и нажми на фото, чтобы увидеть котика',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  void _centerOnMe() {
    final loc = ref.read(mapProvider).myLocation;
    if (loc != null) {
      _mapController.move(loc, 16.5);
    }
  }

  void _showPhoto(CatPhotoEntity photo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CatPhotoSheet(photo: photo),
    );
  }

  Future<void> _captureCat() async {
    if (_isCapturing) return;

    final location = ref.read(mapProvider).myLocation;
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала определяем местоположение…')),
      );
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null || !mounted) return;

      await ref.read(catsProvider.notifier).addPhoto(
            imagePath: image.path,
            location: location,
            authorName: 'Ты',
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🐱 Котик добавлен на карту!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сделать фото. Проверь доступ к камере.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }
}
