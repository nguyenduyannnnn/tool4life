import 'package:flutter/material.dart';

import '../../presentation/widgets/widget.dart';
import 'custom_loading.dart';

class CustomNavigator {
  static push(BuildContext context, Widget screen,
      {bool root = true, bool opaque = true}) {
    CustomLoading.hide();
    return Navigator.of(context, rootNavigator: root).push(opaque
        ? CustomRoute(
            page: screen,
          )
        : CustomRouteDialog(page: screen));
  }

  static popToScreen(BuildContext context, Widget screen, {bool root = true}) {
    CustomLoading.hide();
    Navigator.of(context, rootNavigator: root).popUntil(
        (route) => route.settings.name == screen.runtimeType.toString());
  }

  static popToRoot(BuildContext context, {bool root = true}) {
    CustomLoading.hide();
    Navigator.of(context, rootNavigator: root)
        .popUntil((route) => route.isFirst);
  }

  static pop(BuildContext? context, {dynamic object, bool root = true}) {
    CustomLoading.hide();
    if (object == null)
      Navigator.of(context!, rootNavigator: root).pop();
    else
      Navigator.of(context!, rootNavigator: root).pop(object);
  }

  static canPop(BuildContext context) {
    ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    return parentRoute?.canPop ?? false;
  }

  static pushReplacement(BuildContext context, Widget screen,
      {bool root = true}) {
    CustomLoading.hide();
    Navigator.of(context, rootNavigator: root)
        .pushReplacement(CustomRoute(page: screen));
  }

  static popToRootAndPushReplacement(BuildContext context, Widget screen,
      {bool root = true}) {
    CustomLoading.hide();
    Navigator.of(context, rootNavigator: root)
        .popUntil((route) => route.isFirst);
    Navigator.of(context, rootNavigator: root)
        .pushReplacement(CustomRoute(page: screen));
  }
}
