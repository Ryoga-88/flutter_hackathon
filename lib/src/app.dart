import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';  // テーマをインポート
import 'screens/task.dart';
import 'screens/battle.dart';
import 'screens/status.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // カスタムテーマを適用
      theme: AppTheme.light(),
      // NavigaionBarのClassを呼び出す
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
  // 各画面のリスト
  static const _screens = [
    TaskScreen(),
    BattleScreen(),
    StatusScreen()
  ];
  // 選択されている画面のインデックス
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: _screens[_selectedIndex],
      // 本題のNavigationBar
      bottomNavigationBar: NavigationBar(
        // タップされたタブのインデックスを設定
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        // テーマからセカンダリカラーを取得して使用
        indicatorColor: theme.colorScheme.secondary,  // ここを変更
        selectedIndex: _selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.task_alt),
            label: 'Task',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_martial_arts),
            label: 'Battle',
          ),
          NavigationDestination(
            icon: Icon(Icons.face),
            label: 'Status',
          ),
        ],
      )
    );
  }
}