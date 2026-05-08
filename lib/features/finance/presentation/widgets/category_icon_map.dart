import 'package:flutter/material.dart';

const Map<String, IconData> categoryIconMap = {
  'work': Icons.work_outline,
  'card_giftcard': Icons.card_giftcard,
  'laptop': Icons.laptop_mac_outlined,
  'trending_up': Icons.trending_up,
  'more_horiz': Icons.more_horiz,
  'restaurant': Icons.restaurant_outlined,
  'directions_car': Icons.directions_car_outlined,
  'home': Icons.home_outlined,
  'shopping_bag': Icons.shopping_bag_outlined,
  'favorite': Icons.favorite_outline,
  'movie': Icons.movie_outlined,
  'school': Icons.school_outlined,
};

IconData iconForName(String name) {
  return categoryIconMap[name] ?? Icons.label_outline;
}
