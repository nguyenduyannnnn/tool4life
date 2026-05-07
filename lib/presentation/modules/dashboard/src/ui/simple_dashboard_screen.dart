import 'package:flutter/material.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/home/src/ui/basic_home_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/home/module/recordings/src/ui/recordings_list_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/ui/meetings_screen.dart';

class SimpleDashboardScreen extends StatefulWidget {
  const SimpleDashboardScreen({super.key});

  @override
  State<SimpleDashboardScreen> createState() => _SimpleDashboardScreenState();
}

class _SimpleDashboardScreenState extends State<SimpleDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BasicHomeScreen(),
    const MeetingsScreen(),
    const RecordingsListScreen(),
    const BasicHomeScreen(), // Tạm thời cho tab Tài khoản
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Trang chủ',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.video_call_outlined),
      activeIcon: Icon(Icons.video_call),
      label: 'Cuộc họp',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.mic_outlined),
      activeIcon: Icon(Icons.mic),
      label: 'Ghi âm',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Tài khoản',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        elevation: 2.0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1890FF),
        unselectedItemColor: Colors.grey,
        items: _bottomNavItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
