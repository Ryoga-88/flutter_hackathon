import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';
import 'screens/task.dart';
import 'screens/battle.dart';
import 'screens/status.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: AppTheme.light(),
      home: const BottomNavigation(),
    );
  }
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  static const _screens = [
    TaskScreen(),
    // BattleScreen(),
    StatusScreen(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        indicatorColor: theme.colorScheme.secondary,
        selectedIndex: _selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.task_alt), label: 'Task'),
          // NavigationDestination(
          //   icon: Icon(Icons.sports_martial_arts),
          //   label: 'Battle',
          // ),
          NavigationDestination(icon: Icon(Icons.face), label: 'Status'),
        ],
      ),
    );
  }
}
