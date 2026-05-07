import 'package:flutter/material.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/home/src/ui/simple_home_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/home/module/recordings/src/ui/recordings_list_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/recording/src/ui/recording_screen.dart';
// import 'package:changmeeting/presentation/modules/dashboard/module/statistics/src/ui/statistics_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/profile/src/ui/profile_screen.dart';
import 'package:changmeeting/widgets/recording_bubble.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _pages => [
    const SimpleHomeScreen(),
    RecordingScreen(onTabChange: _changeTab),
    const RecordingsListScreen(),
    // const StatisticsScreen(), // Hidden
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.video_call_outlined),
      activeIcon: Icon(Icons.video_call),
      label: 'Cuộc họp',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.mic_outlined),
      activeIcon: Icon(Icons.mic),
      label: 'Ghi Âm',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.folder_outlined),
      activeIcon: Icon(Icons.folder),
      label: 'Tập tin',
    ),
    // const BottomNavigationBarItem(
    //   icon: Icon(Icons.analytics_outlined),
    //   activeIcon: Icon(Icons.analytics),
    //   label: 'Thống kê',
    // ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Cá nhân',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            _pages[_currentIndex],
            // Recording bubble overlay
            const RecordingBubble(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        elevation: 8.0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        items: _bottomNavItems,
        onTap: _changeTab,
      ),
    );
  }
}
