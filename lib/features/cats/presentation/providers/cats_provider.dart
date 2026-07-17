import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/cat_photo_entity.dart';

class CatsState {
  final List<CatPhotoEntity> photos;
  final bool isLoading;

  const CatsState({
    this.photos = const [],
    this.isLoading = false,
  });

  CatsState copyWith({
    List<CatPhotoEntity>? photos,
    bool? isLoading,
  }) =>
      CatsState(
        photos: photos ?? this.photos,
        isLoading: isLoading ?? this.isLoading,
      );
}

class CatsNotifier extends StateNotifier<CatsState> {
  CatsNotifier() : super(const CatsState(isLoading: true)) {
    _init();
  }

  static const _mockAuthors = ['Маша', 'Дима', 'Катя', 'Саша', 'Лена'];

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.prefKeyCatPhotos);
    final local = <CatPhotoEntity>[];
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      local.addAll(
        list.map((e) => CatPhotoEntity.fromJson(e as Map<String, dynamic>)),
      );
    }
    state = CatsState(photos: local, isLoading: false);
  }

  Future<void> seedMockPhotos(LatLng center) async {
    if (state.photos.any((p) => !p.isLocal)) return;

    final random = Random(42);
    final mock = List.generate(5, (i) {
      final offsetLat = (random.nextDouble() - 0.5) * 0.004;
      final offsetLng = (random.nextDouble() - 0.5) * 0.004;
      return CatPhotoEntity(
        id: 'mock_$i',
        imageUrl: 'https://placekitten.com/${200 + i * 10}/${200 + i * 10}',
        latitude: center.latitude + offsetLat,
        longitude: center.longitude + offsetLng,
        authorName: _mockAuthors[i],
        createdAt: DateTime.now().subtract(Duration(hours: i * 3 + 1)),
        isLocal: false,
      );
    });

    state = state.copyWith(photos: [...state.photos, ...mock]);
  }

  Future<void> addPhoto({
    required String imagePath,
    required LatLng location,
    required String authorName,
  }) async {
    final photo = CatPhotoEntity(
      id: const Uuid().v4(),
      imageUrl: imagePath,
      latitude: location.latitude,
      longitude: location.longitude,
      authorName: authorName,
      createdAt: DateTime.now(),
      isLocal: true,
    );

    final updated = [photo, ...state.photos];
    state = state.copyWith(photos: updated);
    await _persistLocal(updated.where((p) => p.isLocal).toList());
  }

  Future<void> _persistLocal(List<CatPhotoEntity> local) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(local.map((p) => p.toJson()).toList());
    await prefs.setString(AppConstants.prefKeyCatPhotos, json);
  }
}

final catsProvider = StateNotifierProvider<CatsNotifier, CatsState>(
  (ref) => CatsNotifier(),
);
