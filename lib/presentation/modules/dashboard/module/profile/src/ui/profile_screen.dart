import 'package:flutter/material.dart';
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/utils/custom_navigator.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/profile/src/bloc/logout_bloc.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/profile/src/bloc/delete_account_bloc.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/profile/src/ui/edit_profile_screen.dart';
import 'package:changmeeting/presentation/modules/authen_module/src/ui/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LogoutBloc _logoutBloc = LogoutBloc();
  final DeleteAccountBloc _deleteAccountBloc = DeleteAccountBloc();

  @override
  void dispose() {
    _logoutBloc.dispose();
    _deleteAccountBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          StreamBuilder<bool>(
            stream: _logoutBloc.streamIsLoading.stream,
            initialData: false,
            builder: (context, snapshot) {
              final isLoading = snapshot.data ?? false;
              return IconButton(
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.logout, color: Colors.black),
                onPressed: isLoading ? null : () => _showLogoutDialog(context),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Card
            Container(
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
                  // Avatar
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
                        'assets/image/chang_logo.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    Globals.prefs.getString(SharedPrefsKey.userName).isNotEmpty 
                        ? Globals.prefs.getString(SharedPrefsKey.userName) 
                        : 'User',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Username
                  Text(
                    Globals.prefs.getString(SharedPrefsKey.userEmail).isNotEmpty 
                        ? Globals.prefs.getString(SharedPrefsKey.userEmail) 
                        : 'email@example.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => CustomNavigator.push(
                        context,
                        const EditProfileScreen(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items Card
            Container(
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
                  // Tạm thời ẩn các chức năng chưa implement
                  // _buildMenuItem(
                  //   icon: Icons.verified_user,
                  //   title: 'Verification',
                  //   hasCheck: true,
                  //   onTap: () => print('Verification pressed'),
                  // ),
                  // _buildMenuItem(
                  //   icon: Icons.settings,
                  //   title: 'Settings',
                  //   onTap: () => print('Settings pressed'),
                  // ),
                  // _buildMenuItem(
                  //   icon: Icons.lock,
                  //   title: 'Change password',
                  //   onTap: () => print('Change password pressed'),
                  // ),
                  // _buildMenuItem(
                  //   icon: Icons.card_giftcard,
                  //   title: 'Refer friends',
                  //   isLast: true,
                  //   onTap: () => print('Refer friends pressed'),
                  // ),
                  
                  // Placeholder cho các chức năng sẽ implement sau
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.construction,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Các tính năng đang được phát triển',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Verification, Settings, Change Password, Refer Friends',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Delete Account Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: StreamBuilder<bool>(
                stream: _deleteAccountBloc.streamIsLoading.stream,
                initialData: false,
                builder: (context, snapshot) {
                  final isLoading = snapshot.data ?? false;
                  return ElevatedButton(
                    onPressed: isLoading ? null : () => _showDeleteAccountDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red[700],
                      elevation: 0,
                      side: BorderSide(color: Colors.red[200]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_forever,
                                color: Colors.red[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Xóa tài khoản',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    Utilities.customPrint("🗑️ DELETE ACCOUNT: Delete account button pressed, showing dialog");
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StreamBuilder<bool>(
          stream: _deleteAccountBloc.streamIsLoading.stream,
          initialData: false,
          builder: (context, snapshot) {
            final isLoading = snapshot.data ?? false;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red[700],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Xác nhận xóa tài khoản',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: isLoading
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.red,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Đang xóa tài khoản...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bạn có chắc chắn muốn xóa tài khoản không?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '⚠️ Hành động này không thể hoàn tác:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Tất cả dữ liệu sẽ bị xóa vĩnh viễn\n• Các file ghi âm sẽ bị mất\n• Không thể khôi phục tài khoản',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
              actions: isLoading
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Utilities.customPrint("🗑️ DELETE ACCOUNT: User confirmed deletion in dialog");
                          
                          // Get the navigator before closing dialog
                          final navigator = Navigator.of(context, rootNavigator: true);
                          
                          // Close dialog first
                          Navigator.of(dialogContext).pop();
                          
                          // Call delete account API
                          final success = await _deleteAccountBloc.performDeleteAccount();
                          
                          if (success) {
                            Utilities.customPrint("🗑️ DELETE ACCOUNT: Success, navigating to login screen");
                            navigator.pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          } else {
                            Utilities.customPrint("❌ DELETE ACCOUNT: Failed");
                            // Try to show error if possible
                            try {
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    body: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.error, color: Colors.red, size: 64),
                                          const SizedBox(height: 16),
                                          const Text('Xóa tài khoản thất bại'),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Đóng'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } catch (e) {
                              Utilities.customPrint("❌ DELETE ACCOUNT: Cannot show error: $e");
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Xóa tài khoản',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during logout
      builder: (BuildContext dialogContext) {
        return StreamBuilder<bool>(
          stream: _logoutBloc.streamIsLoading.stream,
          initialData: false,
          builder: (context, snapshot) {
            final isLoading = snapshot.data ?? false;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: Colors.red[700],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Xác nhận đăng xuất',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: isLoading
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.red,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Đang đăng xuất...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    )
                  : const Text(
                      'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
                      style: TextStyle(fontSize: 16),
                    ),
              actions: isLoading
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Call logout API and clear data
                          await _logoutBloc.performLogout(context);
                          // Dialog will be closed by navigation to login screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Đồng ý',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
            );
          },
        );
      },
    );
  }
}
