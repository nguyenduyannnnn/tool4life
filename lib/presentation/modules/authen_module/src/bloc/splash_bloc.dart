import 'dart:async';
import 'package:changmeeting/common/utils/custom_navigator.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/ui/dashboard_screen.dart';
import '../../../../base/base_view.dart';
import '../ui/splash_screen.dart';

class SplashBloc extends BaseBloc<SplashScreen> {
  @override
  void onInit() {}

  @override
  void onReady() {
    _goToDashboard();
  }

  Future<void> _goToDashboard() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      CustomNavigator.pushReplacement(context, DashboardScreen());
    }
  }

  @override
  void onResumed() {}

  @override
  void onDispose() {}
}
