import 'package:flutter/material.dart';
import 'package:changmeeting/common/constant.dart';
import 'package:changmeeting/common/localization/l10n.dart';
import 'package:changmeeting/data/models/base/option_model.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import 'package:rxdart/rxdart.dart';
import '../ui/profile_screen.dart';

class ProfileBloc extends BaseBloc<ProfileScreen> {
  final FocusNode focusName = FocusNode();
  final TextEditingController controllerName = TextEditingController();
  final FocusNode focusEmail = FocusNode();
  final TextEditingController controllerEmail = TextEditingController();
  final FocusNode focusAddress1 = FocusNode();
  final TextEditingController controllerAddress1 = TextEditingController();
  final FocusNode focusAddress2 = FocusNode();
  final TextEditingController controllerAddress2 = TextEditingController();
  final FocusNode focusCity = FocusNode();
  final TextEditingController controllerCity = TextEditingController();
  final FocusNode focusState = FocusNode();
  final TextEditingController controllerState = TextEditingController();
  final FocusNode focusZipcode = FocusNode();
  final TextEditingController controllerZipcode = TextEditingController();
  final FocusNode focusNote = FocusNode();
  final TextEditingController controllerNote = TextEditingController();

  final genderModels = [
    OptionModel(
        id: Gender.male.value,
        icon: Icons.male,
        iconColor: Colors.blue,
        text: LangKey.current.male),
    OptionModel(
        id: Gender.female.value,
        icon: Icons.female,
        iconColor: Colors.pink,
        text: LangKey.current.female),
  ];

  final streamBirthday = BehaviorSubject<DateTime?>();
  final streamGenderModel = BehaviorSubject<OptionModel?>();

  DateTime? birthday;
  OptionModel? genderModel;

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
    streamBirthday.close();
    streamGenderModel.close();
  }

  onBirthday() async {
    final event = await showDatePicker(
        context: context,
        firstDate: Constant.minDateTime,
        lastDate: DateTime.now(),
        currentDate: birthday);
    if (event != null) {
      birthday = event;
      streamBirthday.set(birthday);
    }
  }

  onGender(OptionModel model) {
    genderModel = model;
    streamGenderModel.set(genderModel);
  }

  onUpdate() {

  }
}
