import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../widgets/notification_item.dart';
import '../widgets/custom_header.dart';
import '../widgets/confirmation_modal.dart';
import '../widgets/status_modal.dart';
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

  late List<_NotificationData> _notifications;

  bool _isInitialized = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeNotifications();
      _isInitialized = true;
    }
  }

  void _initializeNotifications() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    // Using opacity 0.2 to ensure the yellow color is visible against the dark background
    // while maintaining readability.
    final iconBgColor = primaryColor.withOpacity(0.2);

    _notifications = [
      _NotificationData(
        icon: Icons.warning_amber_rounded,
        title: 'Overvoltage Warning',
        time: 'Today | 03:23 AM',
        isUnread: true,
        iconBackgroundColor: iconBgColor,
        description:
            'The system detected an overvoltage condition (255V) in the main circuit. Automatic protection protocols were engaged to prevent equipment damage. Please check the grid voltage stability.',
      ),
      _NotificationData(
        icon: Icons.thermostat_rounded,
        title: 'High Temperature Alert',
        time: 'Today | 05:23 PM',
        isUnread: false,
        iconBackgroundColor: iconBgColor,
        description:
            'Internal temperature sensors recorded a reading of 55°C, approaching the safety threshold. Cooling fans have been activated at maximum speed. Ensure proper ventilation around the unit.',
      ),
      _NotificationData(
        icon: Icons.check_circle_outline_rounded,
        title: 'System Connected',
        time: 'Friday | 05:00 PM',
        isUnread: false,
        iconBackgroundColor: iconBgColor,
        description:
            'The system has successfully reconnected to the central monitoring server after a brief network interruption. All pending data logs have been synchronized.',
      ),
      _NotificationData(
        icon: Icons.system_update_rounded,
        title: 'Firmware Update Available',
        time: '12 Dec 2024 | 04:00 PM',
        isUnread: false,
        iconBackgroundColor: iconBgColor,
        description:
            'A new firmware version (v2.1.0) is available for your device. This update includes performance improvements for MPPT tracking and bug fixes for communication modules.',
      ),
      _NotificationData(
        icon: Icons.water_drop_rounded,
        title: 'Water Level Critical',
        time: '02 Dec 2024 | 02:00 PM',
        isUnread: false,
        iconBackgroundColor: iconBgColor,
        description:
            'Water level in the reservoir has dropped below 15%. Pump operation has been suspended to prevent dry running. Please check the water source immediately.',
      ),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _deleteNotification(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmationModal(
            title: 'Delete Notification?',
            content:
                'Are you sure you want to delete this notification? This action cannot be undone.',
            onConfirm: () {},
          ),
    );

    if (confirmed == true) {
      // Simulate network delay for effect
      // await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _notifications.removeAt(index);
        });

        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => const StatusModal(
                  type: StatusType.success,
                  title: 'Deleted Successfully',
                  message: 'The notification has been removed from your list.',
                ),
          );
        }
      }
    }
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index].isUnread = false;
    });
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Slidable(
                    key: ValueKey(notification.title + notification.time),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => _markAsRead(index),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          icon: Icons.mark_email_read_rounded,
                          label: 'Read',
                        ),
                        SlidableAction(
                          onPressed: (context) => _deleteNotification(index),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                          icon: Icons.delete_outline_rounded,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: NotificationItem(
                      icon: notification.icon,
                      title: notification.title,
                      time: notification.time,
                      isUnread: notification.isUnread,
                      iconBackgroundColor: notification.iconBackgroundColor,
                      description: notification.description,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationData {
  final IconData icon;
  final String title;
  final String time;
  bool isUnread;
  final Color? iconBackgroundColor;
  final String description;

  _NotificationData({
    required this.icon,
    required this.title,
    required this.time,
    required this.isUnread,
    this.iconBackgroundColor,
    required this.description,
  });
}
