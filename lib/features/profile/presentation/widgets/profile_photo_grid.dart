import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfilePhotoGrid extends StatelessWidget {
  final List<String> photoUrls;

  const ProfilePhotoGrid({super.key, required this.photoUrls});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, i) {
        if (i < photoUrls.length) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              photoUrls[i],
              fit: BoxFit.cover,
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.textSecondary,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}
