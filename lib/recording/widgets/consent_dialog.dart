import 'package:flutter/material.dart';
import 'package:changmeeting/common/theme.dart';

/// Consent dialog for audio upload
/// Shows before first upload to comply with App Store guidelines
/// Explains data processing and asks for explicit user consent
class ConsentDialog extends StatelessWidget {
  final VoidCallback onAgree;
  final VoidCallback onCancel;

  const ConsentDialog({
    super.key,
    required this.onAgree,
    required onCancel,
  }) : onCancel = onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Thông báo xử lý âm thanh',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bản ghi âm của bạn sẽ được tải lên máy chủ của Chang Meeting để chuyển đổi thành văn bản và tạo ghi chú cuộc họp.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dữ liệu được xử lý hoàn toàn trên hạ tầng của Chang Meeting bằng các mô hình AI nội bộ và không được chia sẻ với bất kỳ bên thứ ba nào.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bạn có đồng ý tiếp tục không?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Hủy',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onAgree,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Đồng ý',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}