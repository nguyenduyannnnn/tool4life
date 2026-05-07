import 'package:flutter/material.dart';
import 'package:changmeeting/common/localization/l10n.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import 'package:changmeeting/presentation/widgets/widget.dart';

import '../bloc/register_bloc.dart';

class RegisterScreen extends BaseView {
  final RegisterBloc _bloc = RegisterBloc();
  @override
  RegisterBloc createState() => _bloc;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomScaffold(
      title: "",
      body: CustomAuthenScreen(
        title: LangKey.current.sign_up,
        content: LangKey.current.sign_up_header,
        inputForm: [_buildPhone(), _buildName(), _buildPassword(), _buildConfirmPassword()],
        button1: LangKey.current.sign_up,
        onButton1: _bloc.onSignUp,
      ),
    );
  }

  Widget _buildPhone() {
    return CustomColumnInformation(
      title: LangKey.current.phone_number,
      child: CustomPhoneField(
        focusNode: _bloc.focusPhone,
        controller: _bloc.controllerPhone,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => Utilities.fieldFocus(context, _bloc.focusName),
      ),
    );
  }

  Widget _buildName() {
    return CustomColumnInformation(
      title: LangKey.current.your_name,
      child: CustomTextField(
        focusNode: _bloc.focusName,
        controller: _bloc.controllerName,
        hintText: LangKey.current.your_name,
        suffixIcon: Icons.account_circle,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => Utilities.fieldFocus(context, _bloc.focusPassword),
      ),
    );
  }

  Widget _buildPassword() {
    return CustomColumnInformation(
        title: LangKey.current.password,
        child: CustomPasswordField(
          stream: _bloc.streamPassword,
          focusNode: _bloc.focusPassword,
          controller: _bloc.controllerPassword,
          hintText: LangKey.current.password,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              Utilities.fieldFocus(context, _bloc.focusConfirmPassword),
        ));
  }

  Widget _buildConfirmPassword() {
    return CustomColumnInformation(
        title: LangKey.current.re_enter_password,
        child: CustomPasswordField(
          stream: _bloc.streamConfirmPassword,
          focusNode: _bloc.focusConfirmPassword,
          controller: _bloc.controllerConfirmPassword,
          hintText: LangKey.current.re_enter_password,
          isShowValidation: false,
        ));
  }
}