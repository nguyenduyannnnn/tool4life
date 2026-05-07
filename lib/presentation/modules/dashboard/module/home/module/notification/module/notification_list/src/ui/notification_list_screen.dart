/*
* Created by: tranly
* Created at: 2025/03/07 16:16
*/
import 'package:flutter/material.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/home/module/notification/module/notification_list/src/bloc/notification_list_bloc.dart';

import 'notification_card.dart';

class NotificationListScreen extends BaseView {
  final NotificationListBloc _bloc = NotificationListBloc();
  @override
  NotificationListBloc createState() => _bloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Notification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: _bloc.onReadAll,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final notifications = [
      {
        'title': 'SALES LIVE',
        'content':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua',
        'time': '1h',
        'isRead': false,
        'type': NotificationType.general,
      },
      {
        'title': 'SALES LIVE',
        'content':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua',
        'time': '1h',
        'isRead': false,
        'type': NotificationType.general,
      },
      {
        'title': 'SALES LIVE',
        'content':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua',
        'time': '15 hrs ago',
        'isRead': true,
        'type': NotificationType.general,
      },
      {
        'title': 'SALES LIVE',
        'content':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua',
        'time': '15 hrs ago',
        'isRead': true,
        'type': NotificationType.general,
      },
      {
        'title': 'SALES LIVE',
        'content':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua',
        'time': '15 hrs ago',
        'isRead': true,
        'type': NotificationType.general,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return CustomNotificationCard(
          title: notification['title'] as String,
          content: notification['content'] as String,
          time: notification['time'] as String,
          isRead: notification['isRead'] as bool,
          type: notification['type'] as NotificationType,
        );
      },
    );
  }
}
