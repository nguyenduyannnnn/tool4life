import 'package:flutter/material.dart';

import 'package:changmeeting/common/theme.dart';
import '../../domain/entities/place_tag_entity.dart';

class PlaceTagFilter extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const PlaceTagFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip(label: 'Tất cả', value: null),
          ...PlaceTagEntity.defaults.map(
            (t) => _chip(label: t.name, value: t.id),
          ),
        ],
      ),
    );
  }

  Widget _chip({required String label, required String? value}) {
    final isSelected = value == selected;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onChanged(value),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.accent,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.line,
          ),
        ),
      ),
    );
  }
}
