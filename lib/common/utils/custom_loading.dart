import 'package:flutter/material.dart';

class CustomLoading {
  static BuildContext? _context;
  static show(BuildContext context) {
    if (_context != null) {
      return;
    }

    if (context.mounted) {
      _context = context;
      Navigator.of(_context!, rootNavigator: true).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return PopScope(
              child: Scaffold(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                body: Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              ),
              canPop: false,
            );
          },
        ),
      );
    }
  }

  static hide() {
    if (_context == null) {
      return;
    }
    Navigator.of(_context!, rootNavigator: true).pop();
    _context = null;
  }
}
