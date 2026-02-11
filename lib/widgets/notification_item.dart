import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String description;
  final bool isUnread;
  final Color? iconBackgroundColor;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    required this.description,
    this.isUnread = false,
    this.iconBackgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            isUnread
                ? (isDark
                    ? colorScheme.primary.withValues(alpha: 0.08)
                    : colorScheme.primary.withValues(alpha: 0.04))
                : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isUnread
                  ? colorScheme.primary.withValues(alpha: 0.2)
                  : theme.dividerColor.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          splashColor: colorScheme.primary.withValues(alpha: 0.05),
          highlightColor: Colors.transparent,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Unread Indicator Strip
                if (isUnread)
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Section
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                iconBackgroundColor?.withValues(alpha: 0.2) ??
                                (isUnread
                                    ? colorScheme.primary.withValues(
                                      alpha: 0.15,
                                    )
                                    : theme.dividerColor.withValues(
                                      alpha: 0.1,
                                    )),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 16),
                        // Content Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight:
                                                isUnread
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                            color: colorScheme.onSurface,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    time,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                description,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
