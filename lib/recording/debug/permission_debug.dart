import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:changmeeting/common/utilities.dart';

/// Debug widget để test permission trực tiếp
class PermissionDebug extends StatefulWidget {
  const PermissionDebug({super.key});

  @override
  State<PermissionDebug> createState() => _PermissionDebugState();
}

class _PermissionDebugState extends State<PermissionDebug> {
  String _status = 'Not checked';
  String _logs = '';

  void _addLog(String message) {
    setState(() {
      _logs += '${DateTime.now().toString().substring(11, 19)}: $message\n';
    });
    Utilities.customPrint('🔍 DEBUG: $message');
  }

  Future<void> _checkPermission() async {
    _addLog('Checking microphone permission...');
    try {
      final status = await Permission.microphone.status;
      _addLog('Permission status: $status');
      setState(() {
        _status = status.toString();
      });
    } catch (e) {
      _addLog('Error checking permission: $e');
    }
  }

  Future<void> _requestPermission() async {
    _addLog('Requesting microphone permission...');
    try {
      final status = await Permission.microphone.request();
      _addLog('Permission request result: $status');
      setState(() {
        _status = status.toString();
      });
    } catch (e) {
      _addLog('Error requesting permission: $e');
    }
  }

  Future<void> _openSettings() async {
    _addLog('Opening app settings...');
    try {
      final result = await openAppSettings();
      _addLog('Open settings result: $result');
    } catch (e) {
      _addLog('Error opening settings: $e');
    }
  }

  void _clearLogs() {
    setState(() {
      _logs = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Debug'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_status),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Buttons
            ElevatedButton(
              onPressed: _checkPermission,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Check Permission', style: TextStyle(color: Colors.white)),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _requestPermission,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Request Permission', style: TextStyle(color: Colors.white)),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _openSettings,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _clearLogs,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Clear Logs', style: TextStyle(color: Colors.white)),
            ),
            
            const SizedBox(height: 16),
            
            // Logs
            const Text(
              'Debug Logs:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 8),
            
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _logs.isEmpty ? 'No logs yet...' : _logs,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}