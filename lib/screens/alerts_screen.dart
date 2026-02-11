import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../widgets/notification_item.dart';
import '../widgets/custom_header.dart';
import '../widgets/confirmation_modal.dart';
import '../widgets/status_modal.dart';
import '../constants/app_colors.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationController>().loadNotifications();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _deleteNotification(String id) async {
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
      if (mounted) {
        context.read<NotificationController>().deleteNotification(id);

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

  void _showNotificationDetails(NotificationModel notification) {
    context.read<NotificationController>().markAsRead(notification.id);

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
                        _getIconData(notification.iconName),
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

  IconData _getIconData(String name) {
    switch (name) {
      case 'warning_amber_rounded':
        return Icons.warning_amber_rounded;
      case 'thermostat_rounded':
        return Icons.thermostat_rounded;
      case 'check_circle_outline_rounded':
        return Icons.check_circle_outline_rounded;
      case 'system_update_rounded':
        return Icons.system_update_rounded;
      case 'water_drop_rounded':
        return Icons.water_drop_rounded;
      case 'bolt':
        return Icons.bolt;
      case 'cloud_off':
        return Icons.cloud_off;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomHeader(title: Text('Notification')),
      body: Consumer<NotificationController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notifications.isEmpty) {
            return Center(
              child: Text(
                'No notifications',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadNotifications(),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = controller.notifications[index];

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
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Slidable(
                              key: ValueKey(notification.id),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                extentRatio: 0.25,
                                children: [
                                  CustomSlidableAction(
                                    onPressed:
                                        (context) => _deleteNotification(
                                          notification.id,
                                        ),
                                    backgroundColor: Colors.transparent,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.error,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error
                                            .withValues(alpha: 0.1),
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
                                icon: _getIconData(notification.iconName),
                                title: notification.title,
                                time: notification.time,
                                description: notification.description,
                                isUnread: notification.isUnread,
                                iconBackgroundColor: AppColors.primary,
                                onTap:
                                    () =>
                                        _showNotificationDetails(notification),
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
        },
      ),
    );
  }
}
