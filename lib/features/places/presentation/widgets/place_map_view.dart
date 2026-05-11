import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:changmeeting/common/theme.dart';
import '../../domain/entities/lat_lng.dart';
import '../../domain/entities/place_entity.dart';
import 'place_item.dart';

/// Placeholder map view: chưa enable google_maps_flutter vì xung đột
/// AGP/core dependency. Hiển thị danh sách marker dưới dạng card +
/// "long press" được mô phỏng bằng nút "Thêm tại đây" (dùng vị trí hiện tại).
class PlaceMapView extends StatelessWidget {
  final List<PlaceEntity> places;
  final LatLng? currentLocation;
  final void Function(double lat, double lng) onLongPress;
  final void Function(PlaceEntity place) onMarkerTap;

  const PlaceMapView({
    super.key,
    required this.places,
    required this.currentLocation,
    required this.onLongPress,
    required this.onMarkerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EEF3),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.map_outlined,
                      size: 28, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bản đồ chưa kích hoạt',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Để bật Google Maps: cấp Maps API key vào AndroidManifest.xml + iOS AppDelegate, '
                          'rồi bump AGP/Kotlin lên bản hỗ trợ androidx.core 1.17. '
                          'Hiện tại Places dùng list view + geolocator.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                            height: 1.4,
                          ),
                        ),
                        if (currentLocation != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.my_location,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Vị trí hiện tại: '
                                  '${currentLocation!.latitude.toStringAsFixed(5)}, '
                                  '${currentLocation!.longitude.toStringAsFixed(5)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              TextButton(
                                onPressed: () => onLongPress(
                                  currentLocation!.latitude,
                                  currentLocation!.longitude,
                                ),
                                child: const Text('Thêm tại đây'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: places.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.place_outlined,
                              size: 64, color: AppColors.hint),
                          const SizedBox(height: 12),
                          Text(
                            'Bạn chưa lưu địa điểm nào',
                            style: TextStyle(color: AppColors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nhấn FAB + để thêm',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        final p = places[index];
                        return PlaceItem(
                          place: p,
                          onTap: () => onMarkerTap(p),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper used by detail/list to format the visited date the same way the
// real map view would do in callouts.
String formatVisitedAt(DateTime d) =>
    DateFormat('dd/MM/yyyy').format(d);
