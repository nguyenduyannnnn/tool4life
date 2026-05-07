import 'package:flutter/material.dart';
import 'package:changmeeting/common/localization/l10n.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import 'package:changmeeting/presentation/widgets/widget.dart';

import '../bloc/forget_password_bloc.dart';

class ForgetPasswordScreen extends BaseView {
  final String phone;

  ForgetPasswordScreen({required this.phone});

  final ForgetPasswordBloc _bloc = ForgetPasswordBloc();
  @override
  ForgetPasswordBloc createState() => _bloc;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomScaffold(
      title: "",
      body: CustomAuthenScreen(
        title: LangKey.current.forget_password,
        content: LangKey.current.forget_password_header,
        inputForm: [_buildPhone()],
        button1: LangKey.current.continue_string,
        onButton1: _bloc.onForgetPassword,
      ),
    );
  }

  Widget _buildPhone() {
    return CustomColumnInformation(
      title: LangKey.current.phone_number,
      child: CustomPhoneField(
        focusNode: _bloc.focusPhone,
        controller: _bloc.controllerPhone,
      ),
    );
  }
}
