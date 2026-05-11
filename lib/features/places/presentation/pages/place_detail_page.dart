import 'package:flutter/material.dart';

import '../../domain/entities/place_entity.dart';
import '../widgets/place_marker_detail_sheet.dart';

/// Full-page wrapper around the marker detail content. Currently the app
/// uses [PlaceMarkerDetailSheet] as bottom sheet; this page is provided
/// per spec for future deep-link / standalone navigation.
class PlaceDetailPage extends StatelessWidget {
  final PlaceEntity place;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PlaceDetailPage({
    super.key,
    required this.place,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: SafeArea(
        child: PlaceMarkerDetailSheet(
          place: place,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }
}
