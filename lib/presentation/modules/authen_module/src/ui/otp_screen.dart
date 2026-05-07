import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:changmeeting/common/localization/l10n.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import 'package:changmeeting/presentation/widgets/widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../bloc/otp_bloc.dart';

class OTPScreen extends BaseView {
  final String phone;
  final String? password;

  OTPScreen({required this.phone, this.password});

  final OTPBloc _bloc = OTPBloc();
  @override
  OTPBloc createState() => _bloc;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomScaffold(
      title: "",
      body: CustomAuthenScreen(
        title: LangKey.current.otp_header,
        content: phone,
        inputForm: [_buildOTP()],
        button1: LangKey.current.continue_string,
        onButton1: _bloc.onContinue,
        button2: LangKey.current.send_again,
        onButton2: _bloc.onSendAgain,
      ),
    );
  }

  Widget _buildOTP() {
    return PinCodeTextField(
      controller: _bloc.controllerOTP,
      focusNode: _bloc.focusOTP,
      length: 4,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textStyle: TextStyle(
          fontSize: AppTextSizes.header.value, color: AppColors.primary),
      obscureText: false,
      autoFocus: true,
      enableActiveFill: false,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      pinTheme: PinTheme(
          fieldWidth: AppSizes.maxPadding * 3,
          fieldHeight: AppSizes.maxPadding * 4,
          inactiveColor: AppColors.hint,
          selectedColor: AppColors.hint,
          activeColor: AppColors.primary,
          borderRadius: BorderRadius.circular(10.0)),
      onChanged: (event) {
        if (event.length == 4) {
          _bloc.onContinue();
        }
      },
      appContext: context,
      cursorColor: Colors.black,
    );
  }
}
