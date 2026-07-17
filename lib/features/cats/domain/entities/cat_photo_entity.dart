import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class CatPhotoEntity extends Equatable {
  final String id;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String authorName;
  final DateTime createdAt;
  final bool isLocal;

  const CatPhotoEntity({
    required this.id,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.authorName,
    required this.createdAt,
    this.isLocal = false,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
        'authorName': authorName,
        'createdAt': createdAt.toIso8601String(),
        'isLocal': isLocal,
      };

  factory CatPhotoEntity.fromJson(Map<String, dynamic> json) => CatPhotoEntity(
        id: json['id'] as String,
        imageUrl: json['imageUrl'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        authorName: json['authorName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isLocal: json['isLocal'] as bool? ?? false,
      );

  @override
  List<Object?> get props =>
      [id, imageUrl, latitude, longitude, authorName, createdAt, isLocal];
}
