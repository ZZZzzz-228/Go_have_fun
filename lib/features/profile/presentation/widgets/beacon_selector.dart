import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Список «маяков» статуса — теперь иконки вместо эмодзи.
class _BeaconItem {
  final String label;
  final IconData icon;
  const _BeaconItem(this.label, this.icon);
}

const List<_BeaconItem> _beacons = [
  _BeaconItem('Хочу кофе',        Icons.local_cafe_rounded),
  _BeaconItem('Идём в бар',       Icons.local_bar_rounded),
  _BeaconItem('Гуляю',            Icons.directions_walk_rounded),
  _BeaconItem('Ищу компанию',     Icons.sports_esports_rounded),
  _BeaconItem('На концерт',       Icons.music_note_rounded),
  _BeaconItem('Исследую город',   Icons.travel_explore_rounded),
  _BeaconItem('Хочу перекусить',  Icons.local_pizza_rounded),
  _BeaconItem('Гуляю с собакой',  Icons.pets_rounded),
];

class BeaconSelector extends StatelessWidget {
  final String? selectedLabel;
  final void Function(String label) onSelected;

  const BeaconSelector({
    super.key,
    required this.selectedLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Что ищешь',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Выбери, что хочешь делать прямо сейчас',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _beacons.map((b) {
            final isSelected = selectedLabel == b.label;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(b.label),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        b.icon,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        b.label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
