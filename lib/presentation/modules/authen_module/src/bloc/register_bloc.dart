import 'package:flutter/material.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/common/utils/custom_navigator.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import 'package:rxdart/rxdart.dart';
import '../ui/otp_screen.dart';
import '../ui/register_screen.dart';

class RegisterBloc extends BaseBloc<RegisterScreen> {
  final FocusNode focusPhone = FocusNode();
  final TextEditingController controllerPhone = TextEditingController();
  final FocusNode focusName = FocusNode();
  final TextEditingController controllerName = TextEditingController();
  final FocusNode focusPassword = FocusNode();
  final TextEditingController controllerPassword = TextEditingController();
  final FocusNode focusConfirmPassword = FocusNode();
  final TextEditingController controllerConfirmPassword =
      TextEditingController();

  final streamPassword = BehaviorSubject<bool>();
  final streamConfirmPassword = BehaviorSubject<bool>();

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
    streamPassword.close();
    streamConfirmPassword.close();
  }

  onSignUp() {
    CustomNavigator.push(
        context,
        OTPScreen(
          phone: Utilities.getCountryPhone(controllerPhone.text),
          password: controllerPassword.text,
        ));
  }
}
