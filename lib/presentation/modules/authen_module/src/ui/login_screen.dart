import 'package:flutter/material.dart';
import '../bloc/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginBloc _bloc = LoginBloc();

  @override
  void initState() {
    super.initState();
    // LoginBloc will automatically load remembered credentials in its constructor
    // No need to hardcode here anymore
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main content - scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    _buildLogo(),
                    const SizedBox(height: 32),
                    _buildBrandName(),
                    const SizedBox(height: 80),
                    StreamBuilder<String>(
                      stream: _bloc.streamError.stream,
                      initialData: '',
                      builder: (context, errorSnapshot) {
                        return Column(
                          children: [
                            if (errorSnapshot.data?.isNotEmpty == true)
                              _buildErrorMessage(errorSnapshot.data!),
                            if (errorSnapshot.data?.isNotEmpty == true)
                              const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
                    _buildAzureLoginButton(_bloc, context),
                  ],
                ),
              ),
            ),
            // Footer - FPT Telecom branding
            _buildFptFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E3A8A), // Dark blue background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/image/chang_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback: Tạo logo Chang đơn giản với chữ C
            return Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E3A8A),
              ),
              child: const Center(
                child: Text(
                  'C',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandName() {
    return const Text(
      'Chang Meeting',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildAzureLoginButton(LoginBloc bloc, BuildContext context) {
    return StreamBuilder<bool>(
      stream: bloc.streamIsLoading.stream,
      initialData: false,
      builder: (context, loadingSnapshot) {
        final isLoading = loadingSnapshot.data == true;
        
        return SizedBox(
          width: double.infinity,
          height: 64, // Tăng size từ 56 lên 64
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : () => bloc.onAzureSignIn(context),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF0078D4), // Microsoft blue
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Tăng border radius
              ),
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.1),
            ),
            icon: isLoading 
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Image.asset(
                  'assets/icon/microsoft_icon.png',
                  width: 24, // Tăng size icon từ 20 lên 24
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: Text(
                          'M',
                          style: TextStyle(
                            color: Color(0xFF0078D4),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            label: const Text(
              'Đăng nhập với Microsoft',
              style: TextStyle(
                fontSize: 18, // Tăng font size từ 16 lên 18
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFptFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/image/fpt_telecom_logo.png',
            height: 70,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'FPT Telecom',
                style: TextStyle(
                  color: Color(0xFF0066CC),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Powered by FPT Telecom',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}