import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../common/theme.dart';

abstract class BaseView extends StatefulWidget {
  late final BuildContext context;
  late final Function(VoidCallback) setState;

  @protected
  Widget build(BuildContext context);
}

abstract class BaseBloc<S extends BaseView> extends State<S>
    with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.context = context;
    widget.setState = setState;
    WidgetsBinding.instance.addObserver(this);
    onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    onDispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @protected
  void onInit();

  @protected
  void onReady();

  @protected
  void onResumed();

  @protected
  void onDispose();

  @override
  Widget build(BuildContext context) => widget.build(context);
}

extension BehaviorSubjectExtension<T> on BehaviorSubject<T> {
  set(T event, {Function? function}) {
    function?.call();
    if (!this.isClosed) this.sink.add(event);
  }

  setError(String event, {Function? function}) {
    function?.call();
    if (!this.isClosed) this.sink.addError(event);
  }

  ValueStream<T> get output => this.stream;
}

extension AppContext on BuildContext {
  Size get size => MediaQuery.of(this).size;
  double get width => size.width;
  double get height => size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  double get top => padding.top;
  double get bottom => padding.bottom;
  double get appbar => top + kToolbarHeight;
  double sizePerRow(int itemPerRow, {double? padding, double? separate}) {
    return (width -
            (padding ?? AppSizes.maxPadding) * 2 -
            (separate ?? AppSizes.minPadding) * (itemPerRow - 1) -
            1) /
        itemPerRow;
  }
}
