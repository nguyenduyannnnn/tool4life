import 'package:flutter/material.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/common/utils/custom_navigator.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import 'package:changmeeting/presentation/modules/authen_module/src/ui/otp_screen.dart';

import '../ui/forget_password_screen.dart';

class ForgetPasswordBloc extends BaseBloc<ForgetPasswordScreen> {
  final FocusNode focusPhone = FocusNode();
  final TextEditingController controllerPhone = TextEditingController();

  @override
  void onInit() {
    // TODO: implement onInit
    controllerPhone.text = widget.phone;
  }

  @override
  void onReady() {
    // TODO: implement onReady
  }

  @override
  void onResumed() {
    // TODO: implement onResumed
  }

  @override
  void onDispose() {
    // TODO: implement onDispose
  }

  onForgetPassword() {
    CustomNavigator.push(context,
        OTPScreen(phone: Utilities.getCountryPhone(controllerPhone.text)));
  }
}
