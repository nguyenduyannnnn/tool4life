import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:changmeeting/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:changmeeting/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:changmeeting/features/dashboard/presentation/bloc/main_navigation_cubit.dart';
import 'package:changmeeting/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:changmeeting/features/finance/data/datasources/finance_local_datasource.dart';
import 'package:changmeeting/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:changmeeting/features/places/data/datasources/location_datasource.dart';
import 'package:changmeeting/features/places/data/datasources/places_local_datasource.dart';
import 'package:changmeeting/features/places/data/repositories/places_repository_impl.dart';
import 'package:changmeeting/features/todo/data/datasources/local_database_service.dart';
import 'package:changmeeting/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:changmeeting/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/finance/finance_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/places/places_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/profile/src/ui/profile_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/module/todo/todo_screen.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

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

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const _DashboardTab();
      case 1:
        return const TodoScreen();
      case 2:
        return const FinanceScreen();
      case 3:
        return const PlacesScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MainNavigationCubit>(
      create: (_) => MainNavigationCubit(),
      child: BlocBuilder<MainNavigationCubit, MainNavigationState>(
        buildWhen: (prev, curr) => prev.currentIndex != curr.currentIndex,
        builder: (context, navState) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: _buildPage(navState.currentIndex),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: navState.currentIndex,
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
              onTap: (index) =>
                  context.read<MainNavigationCubit>().changeTab(index),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (ctx) {
        final db = LocalDatabaseService.instance.db;
        final todoRepo = TodoRepositoryImpl(TodoLocalDataSourceImpl(db));
        final financeRepo =
            FinanceRepositoryImpl(FinanceLocalDataSourceImpl(db));
        final placesRepo = PlacesRepositoryImpl(
          localDataSource: PlacesLocalDataSourceImpl(db),
          locationDataSource: LocationDataSourceImpl(),
        );
        final repo = DashboardRepositoryImpl(
          todoRepository: todoRepo,
          financeRepository: financeRepo,
          placesRepository: placesRepo,
        );
        return DashboardBloc(
          getDashboardSummary: GetDashboardSummary(repo),
          mainNavigationCubit: ctx.read<MainNavigationCubit>(),
        );
      },
      child: const DashboardPage(),
    );
  }
}
