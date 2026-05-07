import 'package:flutter/material.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:permission_handler/permission_handler.dart';

/// Widget shown when microphone permission is denied
/// Provides passive UI without aggressive prompting (Apple compliant)
class PermissionDeniedWidget extends StatelessWidget {
  final bool isPermanentlyDenied;
  final VoidCallback? onRetry;

  const PermissionDeniedWidget({
    super.key,
    required this.isPermanentlyDenied,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Warning icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.mic_off,
                size: 40,
                color: Colors.orange,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              isPermanentlyDenied 
                ? 'Quyền truy cập Microphone bị từ chối'
                : 'Không có quyền truy cập Microphone',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              isPermanentlyDenied
                ? 'Để ghi âm, bạn cần bật quyền truy cập microphone trong Cài đặt.'
                : 'Quyền truy cập microphone đã bị từ chối. Bạn có thể bật lại trong Cài đặt.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Action button
            if (isPermanentlyDenied) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await openAppSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Mở Cài đặt',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else if (onRetry != null) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Thử lại',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}