import 'package:flutter/material.dart';
import 'package:changmeeting/recording/overlay/recording_overlay_widget.dart';

/// Entry point for overlay window
/// This runs in a separate isolate from the main app
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RecordingOverlayWidget(),
    ),
  );
}
