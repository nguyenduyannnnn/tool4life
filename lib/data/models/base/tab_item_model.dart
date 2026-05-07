/*
* Created by: tranly
* Created at: 2025/03/03 22:08
*/
import 'package:flutter/material.dart';

class TabItemModel {
  final String title;
  final IconData activeIcon;
  final IconData icon;
  final Widget page;
  bool isSelected = false;
  TabItemModel(
      { required this.page,required this.title,
      required this.activeIcon,
      required this.icon,
      this.isSelected = false});
}
