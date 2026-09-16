import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/timetable_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/more_screen.dart';
import 'widgets/planet_bottom_navigation.dart';

void main() {
  runApp(const PlanetApp());
}

class PlanetApp extends StatelessWidget {
  const PlanetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PLANET',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _dataVersion = 0;

  void _refreshData() {
    setState(() {
      _dataVersion++;
    });
  }

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // 홈 → 수업 화면
  void _openClasses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimetableScreen(
          onChanged: _refreshData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        refreshKey: _dataVersion,
        onClassesTap: _openClasses,
      ),

      // 하단 2번째 = 캘린더
      CalendarScreen(
        refreshKey: _dataVersion,
      ),

      // 계획
      PlanScreen(
        onChanged: _refreshData,
      ),

      // 통계
      StatisticsScreen(
        refreshKey: _dataVersion,
      ),

      // 더보기
      const MoreScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: PlanetBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _changePage,
      ),
    );
  }
}