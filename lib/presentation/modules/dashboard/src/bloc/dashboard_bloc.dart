import 'dart:async';
import 'package:flutter/material.dart';
import 'package:changmeeting/common/utils/custom_navigator.dart';
import 'package:changmeeting/data/models/meeting_model.dart';
import 'package:changmeeting/data/services/meeting_service.dart';
import 'package:changmeeting/presentation/base/base_view.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/ui/main_dashboard_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/home/module/recordings/src/ui/recordings_list_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/ui/dashboard_screen.dart';
import 'package:rxdart/rxdart.dart';

class DashboardBloc extends BaseBloc<DashboardScreen> {
  @override
  void onDispose() {
    streamCurrentIndex.close();
    _meetingsSubject.close();
    searchController.dispose();
  }

  final BehaviorSubject<int> streamCurrentIndex =
      BehaviorSubject<int>.seeded(0);
  final TextEditingController searchController = TextEditingController();
  final BehaviorSubject<List<MeetingModel>> _meetingsSubject =
      BehaviorSubject<List<MeetingModel>>.seeded([]);

  Stream<List<MeetingModel>> get meetingsStream => _meetingsSubject.stream;

  @override
  void onInit() {
    _loadMeetings();
  }

  void _loadMeetings() {
    final meetings = MeetingService.getAllMeetings();
    _meetingsSubject.add(meetings);
  }

  final List<TabItem> tabs = [
    TabItem(
      title: 'Trang chủ',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      page: const MainDashboardScreen(),
    ),
  ];

  void onTab(int index) {
    streamCurrentIndex.add(index);
  }

  @override
  void onReady() {
    // TODO: implement onReady
  }

  @override
  void onResumed() {
    // TODO: implement onResumed
  }

  void onPopInvokedWithResult(bool didPop, dynamic result) {
    // Handle back button
  }

  void onRecordings(BuildContext context) {
    // Navigate to recordings screen
    CustomNavigator.push(context, const RecordingsListScreen());
  }

  // Methods for HomeScreen compatibility
  void onProfile() {
    // TODO: Navigate to profile
  }

  void onNotification() {
    // TODO: Navigate to notifications
  }

  void onSearch(String query) {
    // TODO: Handle search
  }

  void onCreateLabel() {
    // TODO: Navigate to create label
  }

  void onReceiverList() {
    // TODO: Navigate to receiver list
  }

  void onDebtsManagement() {
    // TODO: Navigate to debts management
  }

  void onContact() {
    // TODO: Navigate to contact
  }

  void onLabelsManagement() {
    // TODO: Navigate to labels management
  }

  void onShipmentCurrent() {
    // TODO: Navigate to current shipment
  }

  // Methods for MeetingsScreen
  void onMeetingTap(MeetingModel meeting) {
    // TODO: Navigate to meeting details
    print('Tapped on meeting: ${meeting.title}');
  }

  void onMeetingOptions(MeetingModel meeting) {
    // TODO: Show meeting options
    print('Options for meeting: ${meeting.title}');
  }
}

class TabItem {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final Widget page;

  TabItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.page,
  });
}
