import 'dart:async';
import 'package:flutter/material.dart';
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/repository/delete_account_repository.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class DeleteAccountBloc {
  final DeleteAccountRepository _deleteAccountRepository = DeleteAccountRepository();
  
  final StreamController<bool> _streamIsLoading = StreamController<bool>.broadcast();
  StreamController<bool> get streamIsLoading => _streamIsLoading;

  Future<bool> performDeleteAccount() async {
    try {
      _streamIsLoading.add(true);
      
      Utilities.customPrint("🗑️ DELETE ACCOUNT: Starting delete account process");
      Utilities.customPrint("🗑️ DELETE ACCOUNT: User confirmed deletion, calling API...");
      
      // Call delete account API
      final result = await _deleteAccountRepository.deleteAccount();
      
      Utilities.customPrint("🗑️ DELETE ACCOUNT: API call completed");
      Utilities.customPrint("🗑️ DELETE ACCOUNT: Result - Success: ${result.isSuccess}, Code: ${result.code}, Message: ${result.message}");
      
      if (result.isSuccess) {
        Utilities.customPrint("✅ DELETE ACCOUNT: Account deleted successfully");
        
        // Clear all user data from local storage
        await _clearUserData();
        
        Utilities.customPrint("🗑️ DELETE ACCOUNT: Delete account process completed successfully");
        return true;
      } else {
        Utilities.customPrint("❌ DELETE ACCOUNT: Failed - ${result.message}");
        return false;
      }
    } catch (e) {
      Utilities.customPrint("❌ DELETE ACCOUNT: Exception - ${e.toString()}");
      return false;
    } finally {
      _streamIsLoading.add(false);
    }
  }
  
  Future<void> _clearUserData() async {
    try {
      // Clear all user-related data from SharedPreferences
      await Globals.prefs.removeKey(SharedPrefsKey.token);
      await Globals.prefs.removeKey(SharedPrefsKey.refreshToken);
      await Globals.prefs.removeKey(SharedPrefsKey.userId);
      await Globals.prefs.removeKey(SharedPrefsKey.userName);
      await Globals.prefs.removeKey(SharedPrefsKey.userEmail);
      await Globals.prefs.removeKey(SharedPrefsKey.userRole);
      await Globals.prefs.removeKey(SharedPrefsKey.userLocale);
      await Globals.prefs.removeKey(SharedPrefsKey.userData);
      await Globals.prefs.removeKey(SharedPrefsKey.staffId);
      await Globals.prefs.removeKey(SharedPrefsKey.fishBalance);
      await Globals.prefs.removeKey(SharedPrefsKey.profilePicture);
      
      // Clear login preferences
      await Globals.prefs.removeKey(SharedPrefsKey.rememberLogin);
      await Globals.prefs.removeKey(SharedPrefsKey.rememberedEmail);
      await Globals.prefs.removeKey(SharedPrefsKey.rememberedPassword);
      
      Utilities.customPrint("✅ DELETE ACCOUNT: User data cleared from local storage");
    } catch (e) {
      Utilities.customPrint("❌ DELETE ACCOUNT: Error clearing user data - ${e.toString()}");
    }
  }

  void dispose() {
    _streamIsLoading.close();
  }
}