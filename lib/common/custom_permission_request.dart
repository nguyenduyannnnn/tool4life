import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:changmeeting/common/utils/custom_dialog.dart';
import 'package:changmeeting/common/utils/custom_navigator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'localization/l10n.dart';

class CustomPermissionRequest {
  static Future<bool> request(BuildContext? context, Permission type) async {
    PermissionStatus status = await (await parsePermission(type)).request();
    if (status.isPermanentlyDenied || status.isLimited) {
      String? permission;
      if (type == Permission.camera) {
        permission = LangKey.current.camera;
      } else if (type == Permission.location ||
          type == Permission.locationWhenInUse ||
          type == Permission.locationAlways) {
        permission = LangKey.current.location;
      } else if (type == Permission.storage || type == Permission.photos) {
        permission = LangKey.current.storage;
      } else if (type == Permission.notification) {
        permission = LangKey.current.notification;
      } else if(type == Permission.microphone){
        permission = LangKey.current.microphone;
      }

      if(status.isPermanentlyDenied){
        CustomDialog.showAlert(
            context!,
            "${LangKey.current.message_permission} $permission",
            "${LangKey.current.request_permissions} $permission",
            enableCancel: true,
            textSubmitted: LangKey.current.allow, onSubmitted: () {
          CustomNavigator.pop(context);
          openAppSettings();
        });
      }
      else{
        CustomDialog.showAlert(
            context!,
            "${LangKey.current.message_permission_limited} $permission",
            "${LangKey.current.request_permissions} $permission",
            enableCancel: true,
            textSubmitted: LangKey.current.allow, onSubmitted: () {
          CustomNavigator.pop(context);
          openAppSettings();
        });
      }
    }

    return status.isGranted;
  }

  static Future<bool> check(Permission type) async {
    return (await parsePermission(type)).isGranted;
  }

  static Future<Permission> parsePermission(Permission type) async {
    if(Platform.isAndroid){
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      
      if (type == Permission.photos || type == Permission.storage) {
        if (androidInfo.version.sdkInt <= 32) {
          return Permission.storage;
        }
        return Permission.photos;
      } else if (type == Permission.locationAlways) {
        if (androidInfo.version.sdkInt <= 28) {
          return Permission.location;
        }
      } else if (type == Permission.microphone) {
        // For Android 13+ (API 33+), microphone permission handling
        if (androidInfo.version.sdkInt >= 33) {
          // Android 13+ has more granular audio permissions
          return Permission.microphone;
        }
        return Permission.microphone;
      }
    }
    return type;
  }
}
