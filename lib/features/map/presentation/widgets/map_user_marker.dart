import 'package:flutter/material.dart';
import '../../domain/entities/location_entity.dart';

/// Маркер друга на карте — чёрный "пузырь" с именем и хвостиком-указателем,
/// в духе референса (аватар + подпись ника над точкой)
class MapUserMarker extends StatelessWidget {
  final MapUserEntity user;
  final VoidCallback onTap;

  const MapUserMarker({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Мини-аватар над пузырём
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              gradient: user.isFemale
                  ? const LinearGradient(
                      colors: [Color(0xFFFF4E6A), Color(0xFFFF8E53)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                    ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
            child: user.avatarUrl != null
                ? ClipOval(
                    child: Image.network(user.avatarUrl!, fit: BoxFit.cover),
                  )
                : Center(
                    child: Text(
                      user.isFemale ? '👩' : '👨',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
          ),
          // Чёрный пузырь-бейдж с именем (как на референсе)
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF17171C),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black38, blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  user.beaconEmoji != null
                      ? '${user.beaconEmoji}'
                      : '${user.distanceMeters.round()} м',
                  style: const TextStyle(
                    color: Color(0xFFAFAFC0),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Хвостик пузыря — маленький ромб, "указывающий" на точку на карте
          Transform.rotate(
            angle: 0.785398, // 45°
            child: Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: -4),
              decoration: const BoxDecoration(color: Color(0xFF17171C)),
            ),
          ),
        ],
      ),
    );
  }
}
