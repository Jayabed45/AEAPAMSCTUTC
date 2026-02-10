import 'package:flutter/material.dart';
import '../widgets/notification_item.dart';
import '../widgets/custom_header.dart';
import '../constants/app_colors.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomHeader(title: Text('Notification')),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
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
                    description:
                        'The system detected an overvoltage condition (255V) in the main circuit. Automatic protection protocols were engaged to prevent equipment damage. Please check the grid voltage stability.',
                  ),
                  NotificationItem(
                    icon: Icons.thermostat_rounded,
                    title: 'High Temperature Alert',
                    time: 'Today | 05:23 PM',
                    isUnread: false,
                    iconBackgroundColor: AppColors.secondary.withOpacity(0.15),
                    description:
                        'Internal temperature sensors recorded a reading of 55°C, approaching the safety threshold. Cooling fans have been activated at maximum speed. Ensure proper ventilation around the unit.',
                  ),
                  NotificationItem(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'System Connected',
                    time: 'Friday | 05:00 PM',
                    isUnread: false,
                    iconBackgroundColor: Colors.white.withOpacity(0.1),
                    description:
                        'The system has successfully reconnected to the central monitoring server after a brief network interruption. All pending data logs have been synchronized.',
                  ),
                  NotificationItem(
                    icon: Icons.system_update_rounded,
                    title: 'Firmware Update Available',
                    time: '12 Dec 2024 | 04:00 PM',
                    isUnread: false,
                    iconBackgroundColor: Colors.orange.withOpacity(0.15),
                    description:
                        'A new firmware version (v2.1.0) is available for your device. This update includes performance improvements for MPPT tracking and bug fixes for communication modules.',
                  ),
                  NotificationItem(
                    icon: Icons.water_drop_rounded,
                    title: 'Water Level Critical',
                    time: '02 Dec 2024 | 02:00 PM',
                    isUnread: false,
                    iconBackgroundColor: Colors.blue.withOpacity(0.15),
                    description:
                        'Water level in the reservoir has dropped below 15%. Pump operation has been suspended to prevent dry running. Please check the water source immediately.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
