/*
* Created by: tranly
* Created at: 2025/03/03 21:36
*/
import 'package:flutter/material.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/bloc/dashboard_bloc.dart';

class DashboardScreen extends BaseView {
  @override
  DashboardBloc createState() => DashboardBloc();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: createState().onPopInvokedWithResult,
      child: createState().tabs[0].page,
    );
  }
}
