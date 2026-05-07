import 'package:flutter/material.dart';
import 'package:changmeeting/recording/services/consent_service.dart';
import 'package:changmeeting/recording/services/upload_service.dart';
import 'package:changmeeting/recording/models/recording_model.dart';
import 'package:changmeeting/common/theme.dart';

/// Test screen để kiểm tra consent dialog
class ConsentTestScreen extends StatefulWidget {
  const ConsentTestScreen({super.key});

  @override
  State<ConsentTestScreen> createState() => _ConsentTestScreenState();
}

class _ConsentTestScreenState extends State<ConsentTestScreen> {
  final ConsentService _consentService = ConsentService();
  final UploadService _uploadService = UploadService();
  
  bool _hasConsent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    final hasConsent = await _consentService.hasUserConsent();
    setState(() {
      _hasConsent = hasConsent;
    });
  }

  Future<void> _testConsentDialog() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a mock recording
      final mockRecording = RecordingModel(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        fileName: 'test_recording.m4a',
        filePath: '/path/to/test_recording.m4a',
        duration: 120, // 2 minutes
        createdAt: DateTime.now(),
        fileSize: 512 * 1024, // 512KB
      );

      // This will show consent dialog if user hasn't agreed yet
      final success = await _uploadService.uploadRecording(
        mockRecording, 
        context: context,
      );
      
      // Update consent status
      await _checkConsent();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? '✅ Upload thành công (hoặc user đã đồng ý)' 
                : '❌ Upload bị hủy (user từ chối)',
            ),
            backgroundColor: success ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetConsent() async {
    await _consentService.revokeConsent();
    await _checkConsent();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 Consent đã được reset'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Consent Dialog'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _hasConsent ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _hasConsent ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _hasConsent ? Icons.check_circle : Icons.warning,
                        color: _hasConsent ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Trạng thái Consent',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _hasConsent ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hasConsent 
                      ? 'User đã đồng ý upload lên server Meobeo'
                      : 'User chưa đồng ý upload (sẽ hiện dialog)',
                    style: TextStyle(
                      color: _hasConsent ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Instructions
            const Text(
              'Hướng dẫn test:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Nếu chưa có consent → Nhấn "Test Upload" sẽ hiện dialog\n'
              '2. Chọn "Đồng ý" → Upload sẽ thành công\n'
              '3. Chọn "Hủy" → Upload sẽ bị hủy\n'
              '4. Sau khi đồng ý → Lần sau không hiện dialog nữa\n'
              '5. Nhấn "Reset Consent" để test lại',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Test buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testConsentDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Đang test...'),
                      ],
                    )
                  : const Text(
                      'Test Upload (Sẽ hiện Consent Dialog)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _resetConsent,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Reset Consent (Để test lại)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            const Spacer(),
            
            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 Consent Dialog Content:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Title: "Thông báo xử lý âm thanh"\n\n'
                    'Message: Giải thích rằng audio sẽ được tải lên server Meobeo để xử lý bằng AI nội bộ, không chia sẻ với bên thứ ba.\n\n'
                    'Buttons: "Hủy" / "Đồng ý"',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}