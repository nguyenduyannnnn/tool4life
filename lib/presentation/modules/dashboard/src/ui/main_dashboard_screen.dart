import 'package:flutter/material.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/home/src/ui/simple_home_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/todo/todo_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/finance/finance_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/places/places_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/profile/src/ui/profile_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    SimpleHomeScreen(),
    TodoScreen(),
    FinanceScreen(),
    PlacesScreen(),
    ProfileScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.check_box_outlined),
      activeIcon: Icon(Icons.check_box),
      label: 'Todo',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet_outlined),
      activeIcon: Icon(Icons.account_balance_wallet),
      label: 'Finance',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.place_outlined),
      activeIcon: Icon(Icons.place),
      label: 'Places',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _pages[_currentIndex],
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
        items: _navItems,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
