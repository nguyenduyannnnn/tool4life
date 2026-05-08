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
          'assets/image/tool4life_logo.png',
          width: 200,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              'Tool4Life',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1890FF),
              ),
            );
          },
        ),
      ),
    );
  }
}
