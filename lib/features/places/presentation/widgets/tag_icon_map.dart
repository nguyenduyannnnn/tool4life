import 'package:flutter/material.dart';

const Map<String, IconData> placeTagIconMap = {
  'flight': Icons.flight_takeoff,
  'restaurant': Icons.restaurant_outlined,
  'work': Icons.work_outline,
  'family': Icons.family_restroom,
  'group': Icons.group_outlined,
  'more_horiz': Icons.more_horiz,
};

IconData iconForTag(String? iconName) {
  if (iconName == null) return Icons.place_outlined;
  return placeTagIconMap[iconName] ?? Icons.place_outlined;
}
