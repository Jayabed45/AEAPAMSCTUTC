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
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
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
    _notifications = [
      _NotificationData(
        icon: Icons.warning_amber_rounded,
        title: 'Overvoltage Warning',
        time: 'Today | 03:23 AM',
        isUnread: true,
        iconBackgroundColor: const Color(0xFFFFC107), // Yellow for warning
        description:
            'The system detected an overvoltage condition (255V) in the main circuit. Automatic protection protocols were engaged to prevent equipment damage. Please check the grid voltage stability.',
      ),
      _NotificationData(
        icon: Icons.thermostat_rounded,
        title: 'High Temperature Alert',
        time: 'Today | 05:23 PM',
        isUnread: false,
        iconBackgroundColor: const Color(
          0xFFFF5722,
        ), // Orange/Red for temperature
        description:
            'Internal temperature sensors recorded a reading of 55°C, approaching the safety threshold. Cooling fans have been activated at maximum speed. Ensure proper ventilation around the unit.',
      ),
      _NotificationData(
        icon: Icons.check_circle_outline_rounded,
        title: 'System Connected',
        time: 'Friday | 05:00 PM',
        isUnread: false,
        iconBackgroundColor: const Color(0xFF4CAF50), // Green for success
        description:
            'The system has successfully reconnected to the central monitoring server after a brief network interruption. All pending data logs have been synchronized.',
      ),
      _NotificationData(
        icon: Icons.system_update_rounded,
        title: 'Firmware Update Available',
        time: '12 Dec 2024 | 04:00 PM',
        isUnread: false,
        iconBackgroundColor: const Color(0xFF2196F3), // Blue for info/update
        description:
            'A new firmware version (v2.1.0) is available for your device. This update includes performance improvements for MPPT tracking and bug fixes for communication modules.',
      ),
      _NotificationData(
        icon: Icons.water_drop_rounded,
        title: 'Water Level Critical',
        time: '02 Dec 2024 | 02:00 PM',
        isUnread: false,
        iconBackgroundColor: const Color(0xFF03A9F4), // Light Blue for water
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

  void _showNotificationDetails(_NotificationData notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        notification.icon,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.time,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  notification.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomHeader(title: Text('Notification')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];

                // Create staggered animation for each item
                final itemDelay = index * 100;
                final itemDuration = 600;

                final itemAnimation = CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (itemDelay / 1000).clamp(0.0, 1.0),
                    ((itemDelay + itemDuration) / 1000).clamp(0.0, 1.0),
                    curve: Curves.easeOutQuart,
                  ),
                );

                final itemFade = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(itemAnimation);
                final itemSlide = Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(itemAnimation);

                return FadeTransition(
                  opacity: itemFade,
                  child: SlideTransition(
                    position: itemSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Slidable(
                        key: ValueKey(
                          'notification_${notification.title}_$index',
                        ),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.25,
                          children: [
                            CustomSlidableAction(
                              onPressed:
                                  (context) => _deleteNotification(index),
                              backgroundColor: Colors.transparent,
                              foregroundColor:
                                  Theme.of(context).colorScheme.error,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.error.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        child: NotificationItem(
                          icon: notification.icon,
                          title: notification.title,
                          time: notification.time,
                          isUnread: notification.isUnread,
                          iconBackgroundColor: AppColors.primary,
                          description: notification.description,
                          onTap: () {
                            if (notification.isUnread) {
                              _markAsRead(index);
                            }
                            // Show details in a modal or similar if needed
                            _showNotificationDetails(notification);
                          },
                        ),
                      ),
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
