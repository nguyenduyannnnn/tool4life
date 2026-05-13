import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/features/backup/data/services/backup_service.dart';
import 'package:changmeeting/features/backup/domain/usecases/create_backup.dart';
import 'package:changmeeting/features/backup/domain/usecases/restore_backup.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _userName = 'Dian';
  static const String _userEmail = 'nguyenduyan.annd@gmail.com';
  static const String _userPhone = '+84 384 69 59 79';

  final _backupService = BackupService();
  late final _createBackup = CreateBackup(_backupService);
  late final _restoreBackup = RestoreBackup(_backupService);

  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildBackupCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/image/tool4life_logo.png',
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            _userName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email_outlined, _userEmail),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone_outlined, _userPhone),
        ],
      ),
    );
  }

  Widget _buildBackupCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.backup_outlined,
            iconColor: const Color(0xFF2E7D32),
            title: 'Sao lưu dữ liệu',
            subtitle: 'Xuất toàn bộ dữ liệu ra file .zip để chia sẻ',
            onTap: _busy ? null : _onBackup,
          ),
          const Divider(height: 1, indent: 56),
          _buildActionTile(
            icon: Icons.restore,
            iconColor: const Color(0xFFE65100),
            title: 'Khôi phục dữ liệu',
            subtitle: 'Chọn file .zip đã sao lưu để khôi phục',
            onTap: _busy ? null : _onRestore,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Future<void> _onBackup() async {
    setState(() => _busy = true);
    _showLoading('Đang tạo file sao lưu...');
    File? out;
    try {
      out = await _createBackup();
    } catch (e) {
      _hideLoading();
      _toast('Sao lưu thất bại: $e');
      if (mounted) setState(() => _busy = false);
      return;
    }
    _hideLoading();
    if (mounted) setState(() => _busy = false);

    final size = await out.length();
    await Share.shareXFiles(
      [XFile(out.path, mimeType: 'application/zip')],
      subject: 'tool4life backup',
      text:
          'Sao lưu tool4life (${_formatSize(size)}). Lưu file này vào Drive / iCloud / Files để dùng khi khôi phục.',
    );
  }

  Future<void> _onRestore() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);

    final ok = await _confirmRestore();
    if (ok != true) return;

    setState(() => _busy = true);
    _showLoading('Đang khôi phục dữ liệu...');
    try {
      await _restoreBackup(file);
    } catch (e) {
      _hideLoading();
      _toast('Khôi phục thất bại: $e');
      if (mounted) setState(() => _busy = false);
      return;
    }
    _hideLoading();
    if (mounted) setState(() => _busy = false);

    _toast('Khôi phục thành công. Đang khởi động lại app...');
    await Future<void>.delayed(const Duration(milliseconds: 600));
    Globals.myApp.currentState?.onRefresh();
  }

  Future<bool?> _confirmRestore() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận khôi phục'),
        content: const Text(
          'Khôi phục sẽ ghi đè toàn bộ dữ liệu Todo, Finance và Places hiện tại '
          'bằng dữ liệu trong file sao lưu. Bạn chắc chắn muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Khôi phục'),
          ),
        ],
      ),
    );
  }

  void _showLoading(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Flexible(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  void _hideLoading() {
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) nav.pop();
  }

  void _toast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}
