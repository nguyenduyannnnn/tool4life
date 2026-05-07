import 'package:flutter/material.dart';
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/common/utils/custom_navigator.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import 'package:rxdart/rxdart.dart';

import '../ui/create_password_screen.dart';

class CreatePasswordBloc extends BaseBloc<CreatePasswordScreen> {
  final FocusNode focusPassword = FocusNode();
  final TextEditingController controllerPassword = TextEditingController();
  final FocusNode focusConfirmPassword = FocusNode();
  final TextEditingController controllerConfirmPassword = TextEditingController();

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

  onConfirm() {
    if(Globals.bloc == null) {
      Utilities.login(context);
    }
    else {
      CustomNavigator.pop(context);
    }
  }
}