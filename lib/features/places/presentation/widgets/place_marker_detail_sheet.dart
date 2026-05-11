import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:changmeeting/common/theme.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/entities/place_tag_entity.dart';
import 'tag_icon_map.dart';

class PlaceMarkerDetailSheet extends StatelessWidget {
  final PlaceEntity place;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PlaceMarkerDetailSheet({
    super.key,
    required this.place,
    required this.onEdit,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required PlaceEntity place,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlaceMarkerDetailSheet(
        place: place,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  Future<void> _openDirections() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tag = PlaceTagEntity.findById(place.tag);
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(iconForTag(tag?.icon),
                          size: 22, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          place.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 14, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(place.visitedAt),
                        style: TextStyle(
                            fontSize: 13, color: AppColors.grey),
                      ),
                      if (tag != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag.name,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if ((place.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      place.description!,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                  if (place.imagePaths.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: place.imagePaths.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final f = File(place.imagePaths[i]);
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: f.existsSync()
                                ? Image.file(f,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover)
                                : Container(
                                    width: 120,
                                    height: 120,
                                    color: AppColors.line,
                                    child: const Icon(
                                        Icons.broken_image_outlined),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 14, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${place.latitude.toStringAsFixed(5)}, ${place.longitude.toStringAsFixed(5)}',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onEdit();
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Sửa'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openDirections,
                          icon: const Icon(Icons.directions_outlined, size: 18),
                          label: const Text('Chỉ đường'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onDelete();
                          },
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: Colors.red),
                          label: const Text(
                            'Xóa',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
