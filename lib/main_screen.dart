import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
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
  String _alertsLabel = 'Alerts';
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      AlertsScreen(
        onSectionChanged: (label) {
          if (_selectedIndex == 1) {
            setState(() {
              _alertsLabel = label;
            });
          } else {
            _alertsLabel = label;
          }
        },
      ),
      const SettingsScreen(),
    ];
  }

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
            icon: Icons.notifications_outlined,
            selectedIcon: Icons.notifications,
            label: _alertsLabel,
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
