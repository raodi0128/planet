import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class PlanetBottomNavigation extends StatelessWidget {
  const PlanetBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 72,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: Colors.white,
      indicatorColor:
          AppColors.primary.withOpacity(.13),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon:
              Icon(Icons.home_rounded),
          label: '홈',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.calendar_month_outlined,
          ),
          selectedIcon:
              Icon(Icons.calendar_month_rounded),
          label: '캘린더',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.assignment_outlined,
          ),
          selectedIcon:
              Icon(Icons.assignment_rounded),
          label: '계획',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.bar_chart_outlined,
          ),
          selectedIcon:
              Icon(Icons.bar_chart_rounded),
          label: '통계',
        ),

        NavigationDestination(
          icon: Icon(Icons.more_horiz),
          selectedIcon:
              Icon(Icons.more_horiz),
          label: '더보기',
        ),
      ],
    );
  }
}