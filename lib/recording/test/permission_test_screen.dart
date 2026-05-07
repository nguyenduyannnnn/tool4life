import 'package:flutter/material.dart';
import 'package:changmeeting/recording/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:changmeeting/common/utilities.dart';

/// Simple test screen to verify permission flow works correctly
class PermissionTestScreen extends StatefulWidget {
  const PermissionTestScreen({super.key});

  @override
  State<PermissionTestScreen> createState() => _PermissionTestScreenState();
}

class _PermissionTestScreenState extends State<PermissionTestScreen> {
  final PermissionService _permissionService = PermissionService();
  PermissionStatus? _currentStatus;
  String _lastAction = 'None';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final status = await _permissionService.checkPermission();
    setState(() {
      _currentStatus = status;
      _lastAction = 'Checked status';
    });
  }

  Future<void> _requestPermission() async {
    Utilities.customPrint('🧪 TEST: Requesting permission...');
    final status = await _permissionService.requestPermission();
    setState(() {
      _currentStatus = status;
      _lastAction = 'Requested permission';
    });
    Utilities.customPrint('🧪 TEST: Permission result: $status');
  }

  Future<void> _openSettings() async {
    await _permissionService.openSettings();
    setState(() {
      _lastAction = 'Opened settings';
    });
  }

  Color _getStatusColor() {
    if (_currentStatus == null) return Colors.grey;
    switch (_currentStatus!) {
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.denied:
        return Colors.orange;
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      case PermissionStatus.restricted:
        return Colors.purple;
      case PermissionStatus.limited:
        return Colors.blue;
      case PermissionStatus.provisional:
        return Colors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Permission Status:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getStatusColor()),
                      ),
                      child: Text(
                        _currentStatus?.toString() ?? 'Unknown',
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last action: $_lastAction',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            ElevatedButton(
              onPressed: _checkStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Check Permission Status'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _requestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Request Permission'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _openSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Open App Settings'),
            ),
            
            const SizedBox(height: 20),
            
            // Instructions
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Instructions:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Check status first\n'
                      '2. Tap "Request Permission" to trigger system dialog\n'
                      '3. Try different responses (Allow/Deny)\n'
                      '4. Check logs in console for debug info',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}