import 'package:flutter/material.dart';

import '../../presentation/widgets/widget.dart';
import 'custom_navigator.dart';

class CustomDialog {
  static List<String?> _alertMessage = [];

  static showAlert(BuildContext context, String? title, String? content,
      {bool root = true,
      GestureTapCallback? onSubmitted,
      String? textSubmitted,
      String? textSubSubmitted,
      GestureTapCallback? onSubSubmitted,
      bool enableCancel = false,
      bool cancelable = true,
      bool showSubmitted = true,
      CustomAlertDialogType type = CustomAlertDialogType.info}) async {
    if (_alertMessage.contains(content)) {
      return;
    }
    _alertMessage.add(content);
    dynamic event = await CustomNavigator.push(
        context,
        CustomDialogWidget(
          screen: CustomAlertDialog(
              title: title,
              content: content,
              textSubmitted: textSubmitted,
              onSubmitted: onSubmitted,
              textSubSubmitted: textSubSubmitted,
              onSubSubmitted: onSubSubmitted,
              enableCancel: enableCancel,
              showSubmitted: showSubmitted,
              type: type,),
          cancelable: cancelable,
        ),
        opaque: false,
        root: root);
    _alertMessage.remove(content);
    return event;
  }

  static showPopup(
    BuildContext context,
    Widget child, {
    bool root = true,
    bool isExpanded = false,
    bool cancelable = true,
  }) {
    return CustomNavigator.push(
        context,
        CustomDialogWidget(
          screen: CustomPopupDialog(
            child: child,
            isExpanded: isExpanded,
          ),
          cancelable: cancelable,
        ),
        opaque: false,
        root: root);
  }

  static showBottom(BuildContext context, Widget screen,
      {bool root = true, isScrollControlled = true}) {
    return showModalBottomSheet(
        context: context,
        useRootNavigator: root,
        isScrollControlled: isScrollControlled,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return GestureDetector(
            child: screen,
            onTap: () {},
            behavior: HitTestBehavior.opaque,
          );
        });
  }
}
