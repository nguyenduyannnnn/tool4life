import 'package:flutter/material.dart';
import 'package:changmeeting/common/localization/l10n.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/base/option_model.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import 'package:changmeeting/presentation/widgets/widget.dart';

import '../bloc/profile_bloc.dart';

class ProfileScreen extends BaseView {
  final ProfileBloc _bloc = ProfileBloc();
  @override
  ProfileBloc createState() => _bloc;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomScaffold(
      title: LangKey.current.account_information,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return CustomListView(
      separatorPadding: AppSizes.maxPadding,
      children: [
        _buildPhone(),
        _buildName(),
        _buildEmail(),
        _buildAddress1(),
        _buildAddress2(),
        _buildCity(),
        _buildState(),
        _buildZipcode(),
        _buildNation(),
        _buildBirthday(),
        _buildGender(),
        _buildNote(),
        _buildBottom()
      ],
    );
  }

  Widget _buildPhone() {
    return CustomColumnInformation(
      title: LangKey.current.phone_number,
      content: "+84 987 654 321",
    );
  }

  Widget _buildName() {
    return CustomColumnInformation(
      title: LangKey.current.your_name,
      isRequire: true,
      child: CustomTextField(
        focusNode: _bloc.focusName,
        controller: _bloc.controllerName,
        hintText: LangKey.current.your_name,
        suffixIcon: Icons.account_circle,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => Utilities.fieldFocus(context, _bloc.focusEmail),
      ),
    );
  }

  Widget _buildEmail() {
    return CustomColumnInformation(
      title: LangKey.current.email,
      isRequire: true,
      child: CustomTextField(
        focusNode: _bloc.focusEmail,
        controller: _bloc.controllerEmail,
        hintText: LangKey.current.email,
        suffixIcon: Icons.email,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => Utilities.fieldFocus(context, _bloc.focusAddress1),
      ),
    );
  }

  Widget _buildAddress1() {
    return CustomColumnInformation(
      title: "${LangKey.current.address} 1",
      isRequire: true,
      child: CustomTextField(
        focusNode: _bloc.focusAddress1,
        controller: _bloc.controllerAddress1,
        hintText: LangKey.current.address,
        suffixIcon: Icons.location_on,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => Utilities.fieldFocus(context, _bloc.focusAddress2),
      ),
    );
  }

  Widget _buildAddress2() {
    return CustomColumnInformation(
      title: "${LangKey.current.address} 2",
      child: CustomTextField(
        focusNode: _bloc.focusAddress2,
        controller: _bloc.controllerAddress2,
        hintText: LangKey.current.address,
        suffixIcon: Icons.location_on,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => Utilities.fieldFocus(context, _bloc.focusCity),
      ),
    );
  }

  Widget _buildCity() {
    return CustomColumnInformation(
      title: LangKey.current.city,
      isRequire: true,
      child: CustomTextField(
        focusNode: _bloc.focusCity,
        controller: _bloc.controllerCity,
        hintText: LangKey.current.city,
        suffixIcon: Icons.location_city,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => Utilities.fieldFocus(context, _bloc.focusState),
      ),
    );
  }

  Widget _buildState() {
    return CustomColumnInformation(
      title: LangKey.current.state,
      isRequire: true,
      child: CustomTextField(
        focusNode: _bloc.focusState,
        controller: _bloc.controllerState,
        hintText: LangKey.current.state,
        suffixIcon: Icons.map,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => Utilities.fieldFocus(context, _bloc.focusZipcode),
      ),
    );
  }

  Widget _buildZipcode() {
    return CustomColumnInformation(
      title: LangKey.current.zipcode,
      isRequire: true,
      child: CustomTextField(
        focusNode: _bloc.focusZipcode,
        controller: _bloc.controllerZipcode,
        hintText: LangKey.current.zipcode,
        suffixIcon: Icons.qr_code,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _bloc.onBirthday(),
      ),
    );
  }

  Widget _buildNation() {
    return CustomColumnInformation(
      title: LangKey.current.nation,
      content: LangKey.current.usa,
    );
  }

  Widget _buildBirthday() {
    return CustomColumnInformation(
      title: LangKey.current.birthday,
      isRequire: true,
      child: StreamBuilder(
        stream: _bloc.streamBirthday.output,
        initialData: _bloc.birthday,
        builder: (_, snapshot){
          DateTime? event = snapshot.data;
          return CustomTextField(
            isText: true,
            text: Utilities.formatDate(event),
            hintText: LangKey.current.birthday,
            suffixIcon: Icons.calendar_month,
            onTap: _bloc.onBirthday,
          );
        }
      ),
    );
  }

  Widget _buildGender() {
    return CustomColumnInformation(
      title: LangKey.current.gender,
      isRequire: true,
      child: StreamBuilder(
          stream: _bloc.streamGenderModel.output,
          initialData: _bloc.genderModel,
          builder: (_, snapshot){
            OptionModel? event = snapshot.data;
            return Wrap(
              spacing: AppSizes.minPadding,
              runSpacing: AppSizes.minPadding,
              children: _bloc.genderModels.map((e) => CustomChip.selected(
                text: e.text,
                icon: e.icon,
                iconColor: e.iconColor,
                isSelected: event?.id == e.id,
                onTap: () => _bloc.onGender(e),
              )).toList(),
            );
          }
      ),
    );
  }

  Widget _buildNote() {
    return CustomColumnInformation(
      title: LangKey.current.note,
      isRequire: true,
      child: CustomTextField(
        focusNode: _bloc.focusNote,
        controller: _bloc.controllerNote,
        hintText: LangKey.current.note,
        maxLines: 4,
      ),
    );
  }

  Widget _buildBottom() {
    return CustomButton(
      text: LangKey.current.update,
      onTap: _bloc.onUpdate,
    );
  }
}