import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:changmeeting/common/theme.dart';

class PlaceImagePicker extends StatelessWidget {
  final List<String> imagePaths;
  final ValueChanged<List<String>> onChanged;

  const PlaceImagePicker({
    super.key,
    required this.imagePaths,
    required this.onChanged,
  });

  Future<void> _pick() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    final newList = List<String>.from(imagePaths)
      ..addAll(picked.map((x) => x.path));
    onChanged(newList);
  }

  void _remove(int index) {
    final newList = List<String>.from(imagePaths)..removeAt(index);
    onChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hình ảnh',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imagePaths.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == imagePaths.length) {
                return _addButton();
              }
              return _imageTile(imagePaths[index], () => _remove(index));
            },
          ),
        ),
      ],
    );
  }

  Widget _addButton() {
    return GestureDetector(
      onTap: _pick,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined,
                color: AppColors.primary, size: 24),
            const SizedBox(height: 4),
            const Text(
              'Thêm',
              style: TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageTile(String path, VoidCallback onRemove) {
    final file = File(path);
    return Stack(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.line),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: file.existsSync()
                ? Image.file(file, fit: BoxFit.cover)
                : Container(
                    color: AppColors.line,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
