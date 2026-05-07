import 'package:flutter/material.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import '../bloc/splash_bloc.dart';

class SplashScreen extends BaseView {
  @override
  SplashBloc createState() => SplashBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/image/fpt_telecom_logo.png',
          width: 500,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback nếu chưa có file logo
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0066CC),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'FPT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'FPT Telecom',
                  style: TextStyle(
                    color: Color(0xFF0066CC),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
