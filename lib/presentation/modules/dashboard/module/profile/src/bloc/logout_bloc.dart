import 'package:flutter/material.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/repository/logout_repository.dart';
import 'package:rxdart/rxdart.dart';

class LogoutBloc {
  final streamIsLoading = BehaviorSubject<bool>.seeded(false);
  final _logoutRepository = LogoutRepository();

  void dispose() {
    streamIsLoading.close();
  }

  Future<void> performLogout(BuildContext context) async {
    try {
      streamIsLoading.add(true);

      Utilities.customPrint("🚪 LOGOUT: User initiated logout");

      // Call logout repository (force logout regardless of API result)
      await _logoutRepository.performLogout();

      // Navigate to login screen - data is already cleared by repository
      if (context.mounted) {
        Utilities.logout(context);
      }
    } catch (e) {
      Utilities.customPrint("❌ LOGOUT: Bloc error - ${e.toString()}");

      // Force logout even if there's an error
      if (context.mounted) {
        await Utilities.clearUserData();
        Utilities.logout(context);
      }
    } finally {
      streamIsLoading.add(false);
    }
  }
}
