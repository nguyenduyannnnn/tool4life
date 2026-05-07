import 'package:flutter/material.dart';
import 'package:changmeeting/common/localization/l10n.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import 'package:changmeeting/presentation/widgets/widget.dart';
import '../bloc/create_password_bloc.dart';

class CreatePasswordScreen extends BaseView {
  final CreatePasswordBloc _bloc = CreatePasswordBloc();
  @override
  CreatePasswordBloc createState() => _bloc;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomScaffold(
      title: "",
      body: CustomAuthenScreen(
          title: LangKey.current.create_password,
          content: LangKey.current.create_password_header,
          inputForm: [_buildPassword(), _buildConfirmPassword()],
          button1: LangKey.current.confirm,
          onButton1: _bloc.onConfirm),
    );
  }

  Widget _buildPassword() {
    return CustomColumnInformation(
        title: LangKey.current.new_password,
        child: CustomPasswordField(
          stream: _bloc.streamPassword,
          focusNode: _bloc.focusPassword,
          controller: _bloc.controllerPassword,
          hintText: LangKey.current.new_password,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              Utilities.fieldFocus(context, _bloc.focusConfirmPassword),
        ));
  }

  Widget _buildConfirmPassword() {
    return CustomColumnInformation(
        title: LangKey.current.re_enter_new_password,
        child: CustomPasswordField(
          stream: _bloc.streamConfirmPassword,
          focusNode: _bloc.focusConfirmPassword,
          controller: _bloc.controllerConfirmPassword,
          hintText: LangKey.current.re_enter_new_password,
          isShowValidation: false,
        ));
  }
}
