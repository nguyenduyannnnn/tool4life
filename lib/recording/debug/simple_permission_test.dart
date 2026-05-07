import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Test đơn giản nhất để kiểm tra permission
class SimplePermissionTest extends StatefulWidget {
  const SimplePermissionTest({super.key});

  @override
  State<SimplePermissionTest> createState() => _SimplePermissionTestState();
}

class _SimplePermissionTestState extends State<SimplePermissionTest> {
  String _result = 'Chưa test';

  Future<void> _testPermission() async {
    print('🧪 Starting permission test...');
    
    try {
      // 1. Check current status
      final currentStatus = await Permission.microphone.status;
      print('🔍 Current status: $currentStatus');
      
      // 2. Request permission
      print('📱 Requesting permission...');
      final requestResult = await Permission.microphone.request();
      print('✅ Request result: $requestResult');
      
      // 3. Check status after request
      final finalStatus = await Permission.microphone.status;
      print('🏁 Final status: $finalStatus');
      
      setState(() {
        _result = '''
Current: $currentStatus
Requested: $requestResult  
Final: $finalStatus
        ''';
      });
      
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Permission Test'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Test Permission Trực Tiếp',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 40),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _result,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _testPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'TEST PERMISSION',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Xem console logs để theo dõi chi tiết',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}