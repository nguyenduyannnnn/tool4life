import 'package:flutter/material.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/common/utils/custom_navigator.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import 'package:changmeeting/presentation/modules/authen_module/src/ui/create_password_screen.dart';

import '../ui/otp_screen.dart';

class OTPBloc extends BaseBloc<OTPScreen> {
  final FocusNode focusOTP = FocusNode();
  final TextEditingController controllerOTP = TextEditingController();

  @override
  void onInit() {
    // TODO: implement onInit
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

  onContinue() {
    if(widget.password == null) {
      CustomNavigator.pushReplacement(context, CreatePasswordScreen());
    }
    else {
      Utilities.login(context);
    }
  }

  onSendAgain() {

  }
}