import 'package:flutter/material.dart';

class Constant {
  static String langDefault = langVi;
  static const String android = "android";
  static const String ios = "ios";
  static const String langVi = "vi";
  static const String langEn = "en";

  // String
  static final String decimalSymbol = ".";

  // DateTime
  static final DateTime minDateTime = DateTime(1900, 1, 1);
}

// typedef
typedef CustomRefreshCallback = Future<void> Function();
typedef CustomBodyBuilder = Widget Function();

enum RegPattern {
  uppercase("(?=.*?[A-Z])"),
  lowercase("(?=.*?[a-z])"),
  number("(?=.*?[0-9])"),
  special("(?=.*?[!@#\$&*~])"),
  passwordLength(".{8,}"),
  email(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

  const RegPattern(this.value);

  final String value;
}

enum Gender {
  male("male"),
  female("female");

  const Gender(this.value);

  final String value;
}
