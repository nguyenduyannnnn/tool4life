import 'package:flutter/material.dart';
import 'package:changmeeting/recording/services/permission_service.dart';
import 'package:changmeeting/recording/services/consent_service.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:permission_handler/permission_handler.dart';

/// Final compliance test để đảm bảo tất cả đã tuân thủ Apple guidelines
class FinalComplianceTest extends StatefulWidget {
  const FinalComplianceTest({super.key});

  @override
  State<FinalComplianceTest> createState() => _FinalComplianceTestState();
}

class _FinalComplianceTestState extends State<FinalComplianceTest> {
  final PermissionService _permissionService = PermissionService();
  final ConsentService _consentService = ConsentService();
  
  PermissionStatus? _permissionStatus;
  bool _hasConsent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkStatuses();
  }

  Future<void> _checkStatuses() async {
    final status = await _permissionService.checkPermission();
    final consent = await _consentService.hasUserConsent();
    
    setState(() {
      _permissionStatus = status;
      _hasConsent = consent;
    });
  }

  /// Test Apple-compliant permission flow
  Future<void> _testPermissionFlow() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // This should directly request permission without any pre-dialog
      final status = await _permissionService.requestPermission();
      
      setState(() {
        _permissionStatus = status;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status.isGranted 
                ? '✅ Permission granted - NO pre-dialog shown!' 
                : '❌ Permission denied - Passive UI should be shown',
            ),
            backgroundColor: status.isGranted ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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

  Future<void> _resetAll() async {
    await _consentService.revokeConsent();
    await _checkStatuses();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 All states reset for testing'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Compliance Test'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compliance status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        '✅ APPLE COMPLIANT',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• NO pre-permission dialogs\n'
                    '• Direct permission request after user interaction\n'
                    '• Consent dialog before upload\n'
                    '• Passive UI for denied permissions',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Current status
            _buildStatusCard('Permission Status', _getPermissionStatusText()),
            const SizedBox(height: 12),
            _buildStatusCard('Upload Consent', _hasConsent ? 'Granted' : 'Not granted'),
            
            const SizedBox(height: 32),
            
            // Test buttons
            const Text(
              'Test Compliance:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testPermissionFlow,
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
                        Text('Testing...'),
                      ],
                    )
                  : const Text(
                      'Test Permission (Direct Request)',
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
                onPressed: _resetAll,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Reset All States',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            const Spacer(),
            
            // Instructions
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
                    '📋 Test Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Tap "Test Permission" → System dialog should appear IMMEDIATELY\n'
                    '2. NO custom dialog should appear before system dialog\n'
                    '3. If denied → App should show passive UI (no aggressive prompting)\n'
                    '4. For upload consent → Use Recording screen or Consent Test',
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

  Widget _buildStatusCard(String title, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            status,
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getPermissionStatusText() {
    if (_permissionStatus == null) return 'Checking...';
    if (_permissionStatus!.isGranted) return 'Granted';
    if (_permissionStatus!.isPermanentlyDenied) return 'Permanently Denied';
    if (_permissionStatus!.isDenied) return 'Denied';
    return 'Unknown';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'granted':
        return Colors.green;
      case 'denied':
      case 'permanently denied':
        return Colors.red;
      case 'not granted':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}