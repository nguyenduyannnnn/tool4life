import 'package:flutter/material.dart';

class RecordingScreen extends StatelessWidget {
  final Function(int)? onTabChange;

  const RecordingScreen({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(child: Text('')),
    );
  }
}
