import 'package:flutter/material.dart';

class OptionModel {
  final dynamic id;
  final IconData? icon;
  final Color? iconColor;
  final String? text;

  OptionModel(
      {required this.id, this.icon, this.iconColor, required this.text});
}
