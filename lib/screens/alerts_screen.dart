import 'package:flutter/material.dart';
import '../widgets/notification_item.dart';
import '../widgets/custom_header.dart';
import '../constants/app_colors.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomHeader(
        title: Text('Notification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              NotificationItem(
                icon: Icons.warning_amber_rounded,
                title: 'Overvoltage Warning',
                time: 'Today | 03:23 AM',
                isUnread: true,
                iconBackgroundColor: AppColors.primary.withOpacity(0.15),
              ),
              NotificationItem(
                icon: Icons.thermostat_rounded,
                title: 'High Temperature Alert',
                time: 'Today | 05:23 PM',
                isUnread: false,
                iconBackgroundColor: AppColors.secondary.withOpacity(0.15),
              ),
              NotificationItem(
                icon: Icons.check_circle_outline_rounded,
                title: 'System Connected',
                time: 'Friday | 05:00 PM',
                isUnread: false,
                iconBackgroundColor: Colors.white.withOpacity(0.1),
              ),
              NotificationItem(
                icon: Icons.system_update_rounded,
                title: 'Firmware Update Available',
                time: '12 Dec 2024 | 04:00 PM',
                isUnread: false,
                iconBackgroundColor: Colors.orange.withOpacity(0.15),
              ),
              NotificationItem(
                icon: Icons.water_drop_rounded,
                title: 'Water Level Critical',
                time: '02 Dec 2024 | 02:00 PM',
                isUnread: false,
                iconBackgroundColor: Colors.blue.withOpacity(0.15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
