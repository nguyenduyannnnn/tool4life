import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:changmeeting/common/theme.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/entities/place_tag_entity.dart';
import 'tag_icon_map.dart';

class PlaceItem extends StatelessWidget {
  final PlaceEntity place;
  final VoidCallback onTap;

  const PlaceItem({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tag = PlaceTagEntity.findById(place.tag);
    final firstImage =
        place.imagePaths.isEmpty ? null : File(place.imagePaths.first);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: firstImage != null && firstImage.existsSync()
                  ? Image.file(firstImage,
                      width: 56, height: 56, fit: BoxFit.cover)
                  : Container(
                      width: 56,
                      height: 56,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(iconForTag(tag?.icon),
                          color: AppColors.primary),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd/MM/yyyy').format(place.visitedAt),
                    style: TextStyle(
                        fontSize: 12, color: AppColors.grey),
                  ),
                  if (tag != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      tag.name,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
