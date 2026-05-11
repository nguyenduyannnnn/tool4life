import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:changmeeting/common/theme.dart';
import '../../data/datasources/place_image_storage.dart';
import '../../domain/entities/place_entity.dart';
import '../widgets/place_form.dart';

class PlaceFormBottomSheet extends StatelessWidget {
  final PlaceEntity? initial;
  final double initialLat;
  final double initialLng;

  const PlaceFormBottomSheet({
    super.key,
    this.initial,
    required this.initialLat,
    required this.initialLng,
  });

  static Future<PlaceEntity?> show(
    BuildContext context, {
    PlaceEntity? initial,
    required double initialLat,
    required double initialLng,
  }) {
    return showModalBottomSheet<PlaceEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlaceFormBottomSheet(
        initial: initial,
        initialLat: initialLat,
        initialLng: initialLng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = initial != null;
    final mq = MediaQuery.of(context);

    final formInitial = PlaceFormData(
      name: initial?.name ?? '',
      description: initial?.description ?? '',
      visitedAt: initial?.visitedAt ?? DateTime.now(),
      latitude: initial?.latitude ?? initialLat,
      longitude: initial?.longitude ?? initialLng,
      tag: initial?.tag,
      imagePaths: initial?.imagePaths ?? const [],
    );

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        constraints: BoxConstraints(
          maxHeight: mq.size.height * 0.92,
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                isEdit ? 'Sửa địa điểm' : 'Thêm địa điểm',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              PlaceForm(
                initial: formInitial,
                submitLabel: isEdit ? 'Cập nhật' : 'Lưu',
                onSubmit: (data) async {
                  final id = initial?.id ?? const Uuid().v4();
                  final now = DateTime.now();

                  // Persist any newly picked images (not yet under app docs)
                  final persistedPaths = <String>[];
                  for (final path in data.imagePaths) {
                    if (path.contains('/places/$id/')) {
                      persistedPaths.add(path);
                    } else {
                      try {
                        final stored = await PlaceImageStorage.instance
                            .persist(path, id);
                        persistedPaths.add(stored);
                      } catch (_) {
                        persistedPaths.add(path);
                      }
                    }
                  }

                  // Best-effort delete files that were removed from the form
                  if (initial != null) {
                    final removed = initial!.imagePaths
                        .where((p) => !persistedPaths.contains(p))
                        .toList();
                    await PlaceImageStorage.instance.deleteAll(removed);
                  }

                  final entity = PlaceEntity(
                    id: id,
                    name: data.name,
                    description:
                        data.description.isEmpty ? null : data.description,
                    latitude: data.latitude,
                    longitude: data.longitude,
                    imagePaths: persistedPaths,
                    visitedAt: data.visitedAt,
                    tag: data.tag,
                    createdAt: initial?.createdAt ?? now,
                    updatedAt: initial == null ? null : now,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop(entity);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
