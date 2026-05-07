/*
* Created by: tranly
* Created at: 2025/03/08 20:31
*/
import 'package:flutter/material.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/home/module/notification/module/notification_details/src/bloc/notification_details_bloc.dart';
import 'package:changmeeting/presentation/widgets/widget.dart';

class NotificationDetailsScreen extends BaseView {
  final NotificationDetailsBloc _bloc = NotificationDetailsBloc();
  @override
  NotificationDetailsBloc createState() => _bloc;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomScaffold(
      title: "Chi tiết thông báo",
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return CustomListView(
      children: [],
    );
  }
}
