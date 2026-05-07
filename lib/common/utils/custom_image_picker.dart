import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../presentation/widgets/widget.dart';
import '../localization/l10n.dart';
import 'custom_dialog.dart';
import 'custom_navigator.dart';
import 'custom_permission_request.dart';

class CustomImagePicker {
  static showPicker(BuildContext context, Function(File) onConfirm,
      {bool isSelfie = false}) {
    CustomDialog.showBottom(
        context,
        CustomBottomSheet(
            body: CustomBottomOption(
              options: [
                CustomBottomOptionModel(
                    text: LangKey.current.capture,
                    onTap: () async {
                      File? file = await pickImage(context, ImageSource.camera,
                          isSelfie: isSelfie);
                      if (file != null) {
                        onConfirm(file);
                      }
                    }),
                CustomBottomOptionModel(
                    text: LangKey.current.select_from_gallery,
                    onTap: () async {
                      File? file = await pickImage(context, ImageSource.gallery);
                      if (file != null) {
                        onConfirm(file);
                      }
                    })
              ],
            )));
  }

  static showMultiPicker(BuildContext context, Function(List<File>)? onConfirm,
      {bool isSelfie = false}) {
    CustomDialog.showBottom(
        context,
        CustomBottomSheet(
            body: CustomBottomOption(
              options: [
                CustomBottomOptionModel(
                    text: LangKey.current.capture,
                    onTap: () async {
                      File? file = await pickImage(context, ImageSource.camera,
                          isSelfie: isSelfie);
                      if (file != null) {
                        onConfirm!([file]);
                      }
                    }),
                CustomBottomOptionModel(
                    text: LangKey.current.select_from_gallery,
                    onTap: () async {
                      List<File>? files = await pickMultiImage(context);
                      if (files != null) {
                        onConfirm!(files);
                      }
                    })
              ],
            )));
  }

  static Future<File?> pickImage(BuildContext? context, ImageSource source,
      {bool isSelfie = false}) async {
    try {
      bool permission = false;
      if (source == ImageSource.camera) {
        permission =
        await CustomPermissionRequest.request(context, Permission.camera);
      } else {
        permission =
        await checkPhotoPermission(context!);
      }
      if (!permission) return null;
    } catch (_) {
      return null;
    }

    final pickedFile = await ImagePicker().pickImage(
      source: source,
      preferredCameraDevice: isSelfie ? CameraDevice.front : CameraDevice.rear,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 50
    );

    if (pickedFile == null) return null;

    return File(pickedFile.path);
  }

  static Future<List<File>?> pickMultiImage(BuildContext? context) async {
    bool permission = await checkPhotoPermission(context!);

    if (!permission) {
      return null;
    }

    List<XFile> pickedFile = await ImagePicker().pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 50
    );
    if (pickedFile.isEmpty) return null;
    return pickedFile.map((e) => File(e.path)).toList();
  }

  static Future<bool> checkPhotoPermission(BuildContext context) async {
    Permission permission =
    await CustomPermissionRequest.parsePermission(Permission.photos);

    if (await permission.isPermanentlyDenied) {
      CustomDialog.showAlert(
          context,
          "${LangKey.current.request_permissions} ${LangKey.current.storage}",
          "${LangKey.current.message_permission} ${LangKey.current.storage}",
          enableCancel: true,
          textSubmitted: LangKey.current.allow, onSubmitted: () {
        CustomNavigator.pop(context);
        openAppSettings();
      });
      return false;
    }

    if (await permission.isLimited) {
      bool? event = await CustomDialog.showAlert(
          context,
          "${LangKey.current.request_permissions} ${LangKey.current.storage}",
          LangKey.current.message_permission_limited,
          enableCancel: true,
          textSubmitted: LangKey.current.allow,
          onSubmitted: () {
            CustomNavigator.pop(context, object: true);
          },
          textSubSubmitted: LangKey.current.still_access,
          onSubSubmitted: () {
            CustomNavigator.pop(context, object: false);
          });

      if (event == null) {
        return false;
      }
      if (event) {
        openAppSettings();
        return false;
      }
    }

    return true;
  }
}
