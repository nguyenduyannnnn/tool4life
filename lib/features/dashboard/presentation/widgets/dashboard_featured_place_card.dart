import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:changmeeting/common/theme.dart';
import '../../../places/domain/entities/place_entity.dart';
import '../../../places/domain/entities/place_tag_entity.dart';
import '../../../places/presentation/widgets/tag_icon_map.dart';

class DashboardFeaturedPlaceCard extends StatelessWidget {
  final PlaceEntity? featuredPlace;
  final String? imagePath;
  final VoidCallback? onOpenPlace;

  const DashboardFeaturedPlaceCard({
    super.key,
    required this.featuredPlace,
    required this.imagePath,
    required this.onOpenPlace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onOpenPlace,
            child: featuredPlace != null && imagePath != null
                ? _buildWithImage()
                : _buildPlaceholder(),
          ),
        ),
      ),
    );
  }

  Widget _buildWithImage() {
    final place = featuredPlace!;
    final tag = PlaceTagEntity.findById(place.tag);
    final file = File(imagePath!);
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (file.existsSync())
            Image.file(file, fit: BoxFit.cover)
          else
            Container(
              color: AppColors.line,
              child: const Icon(Icons.broken_image_outlined, size: 48),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 12, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    'Kỷ niệm gần nhất',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(place.visitedAt),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    if (tag != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(iconForTag(tag.icon),
                                size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              tag.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 170,
      width: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_library_outlined,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Chưa có kỷ niệm nào',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Thêm địa điểm đã đến',
            style: TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
