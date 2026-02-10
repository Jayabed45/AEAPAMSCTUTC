import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/graphs_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/custom_animated_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const GraphsScreen(),
    const AlertsScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomAnimatedNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
        backgroundColor: Theme.of(context).cardColor,
        items: [
          CustomNavBarItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
          ),
          CustomNavBarItem(
            icon: Icons.show_chart,
            selectedIcon: Icons.show_chart,
            label: 'Graphs',
          ),
          CustomNavBarItem(
            icon: Icons.notifications_outlined,
            selectedIcon: Icons.notifications,
            label: 'Alerts',
          ),
          CustomNavBarItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
